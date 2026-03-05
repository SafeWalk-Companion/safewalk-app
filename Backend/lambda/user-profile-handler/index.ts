import { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import * as https from 'https';
import * as http from 'http';

const dynamoClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(dynamoClient);

interface GenerateSharingCodeRequest {
  userId: string;
}

interface ConnectWithCodeRequest {
  userId: string;
  sharingCode: string;
}

interface PlatformSharingCodePayload {
  safeWalkId: string;
}

/** Response from POST /sharing-codes on the platform --> valid for 24 hours. */
interface PlatformSharingCodeResponse {
  success: boolean;
  data: {
    sharingCode: string;
    safeWalkId: string;
    createdAt: string;
    expiresAt: string;
  };
}

interface PlatformTrustedContactPayload {
  requesterSafeWalkId: string;
  sharingCode: string;
}

interface PlatformTrustedContactResponse {
  success: boolean;
  data?: Record<string, unknown>;
}

const getEnv = (name: string): string | undefined => process.env[name];

const missingEnvResponse = (name: string): APIGatewayProxyResultV2 => ({
  statusCode: 500,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ error: `Server configuration error: ${name} not set` }),
});

const jsonResponse = (statusCode: number, body: unknown): APIGatewayProxyResultV2 => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(body),
});

export const handler = async (event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const tableName = getEnv('TABLE_NAME');
  if (!tableName) return missingEnvResponse('TABLE_NAME');

  switch (event.routeKey) {
    case 'GET /sharing-code':
      return handleGetSharingCode(event, tableName);

    case 'POST /sharing-code':
      return handleGenerateSharingCode(event, tableName);

    case 'POST /sharing-code/connect':
      return handleConnectWithCode(event, tableName);

    default:
      return jsonResponse(404, { error: 'Route not found' });
  }
};

async function handleGetSharingCode(
  event: APIGatewayProxyEventV2,
  tableName: string,
): Promise<APIGatewayProxyResultV2> {
  const userId = event.queryStringParameters?.userId;
  if (!userId) {
    return jsonResponse(400, { error: 'userId query parameter is required' });
  }

  try {
    const result = await docClient.send(
      new GetCommand({ TableName: tableName, Key: { safeWalkAppId: userId } }),
    );

    if (!result.Item) {
      return jsonResponse(404, { error: 'User not found' });
    }

    const { sharingCode, sharingCodeExpiresAt } = result.Item;
    if (!sharingCode || !sharingCodeExpiresAt) {
      return jsonResponse(404, { error: 'No sharing code found for this user' });
    }

    return jsonResponse(200, { sharingCode, sharingCodeExpiresAt });
  } catch (error) {
    console.error('Error fetching sharing code:', error);
    return jsonResponse(500, {
      error: 'Failed to retrieve sharing code',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
}

async function handleGenerateSharingCode(
  event: APIGatewayProxyEventV2,
  tableName: string,
): Promise<APIGatewayProxyResultV2> {
  const platformBaseDomain = getEnv('PLATFORM_DOMAIN');
  if (!platformBaseDomain) return missingEnvResponse('PLATFORM_DOMAIN');

  const apiKey = getEnv('API_KEY');
  if (!apiKey) return missingEnvResponse('API_KEY');

  let requestBody: GenerateSharingCodeRequest;
  try {
    if (!event.body) return jsonResponse(400, { error: 'Request body is required' });
    requestBody = JSON.parse(event.body) as GenerateSharingCodeRequest;
  } catch {
    return jsonResponse(400, { error: 'Invalid JSON in request body' });
  }

  if (!requestBody.userId || typeof requestBody.userId !== 'string') {
    return jsonResponse(400, { error: 'userId is required and must be a string' });
  }

  let safeWalkId: string;
  try {
    const result = await docClient.send(
      new GetCommand({ TableName: tableName, Key: { safeWalkAppId: requestBody.userId } }),
    );

    if (!result.Item?.safeWalkId) {
      return jsonResponse(400, { error: 'User has not been registered on the platform yet' });
    }
    safeWalkId = result.Item.safeWalkId as string;
  } catch (error) {
    console.error('Error retrieving user:', error);
    return jsonResponse(500, {
      error: 'Failed to retrieve user data',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }

  const sharingCodesUrl = `${platformBaseDomain}/sharing-codes`;
  const payload: PlatformSharingCodePayload = { safeWalkId };

  try {
    const platformResponse = await sendRequest<PlatformSharingCodeResponse>(
      sharingCodesUrl,
      payload,
      apiKey,
    );

    if (!platformResponse.success || !platformResponse.data?.sharingCode || !platformResponse.data?.expiresAt) {
      console.error('Invalid platform sharing code response:', platformResponse);
      return jsonResponse(502, {
        error: 'Invalid platform response',
        details: 'Sharing code response missing required fields',
      });
    }

    const { sharingCode, expiresAt: sharingCodeExpiresAt } = platformResponse.data;

    await docClient.send(
      new UpdateCommand({
        TableName: tableName,
        Key: { safeWalkAppId: requestBody.userId },
        UpdateExpression:
          'SET sharingCode = :sharingCode, sharingCodeExpiresAt = :sharingCodeExpiresAt, updatedAt = :updatedAt',
        ExpressionAttributeValues: {
          ':sharingCode': sharingCode,
          ':sharingCodeExpiresAt': sharingCodeExpiresAt,
          ':updatedAt': new Date().toISOString(),
        },
      }),
    );

    console.log('Sharing code generated and stored for user:', requestBody.userId);
    return jsonResponse(200, { sharingCode, sharingCodeExpiresAt });
  } catch (error) {
    console.error('Error generating sharing code:', error);
    return jsonResponse(502, {
      error: 'Failed to generate sharing code',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
}

async function handleConnectWithCode(
  event: APIGatewayProxyEventV2,
  tableName: string,
): Promise<APIGatewayProxyResultV2> {
  const platformBaseDomain = getEnv('PLATFORM_DOMAIN');
  if (!platformBaseDomain) return missingEnvResponse('PLATFORM_DOMAIN');

  const apiKey = getEnv('API_KEY');
  if (!apiKey) return missingEnvResponse('API_KEY');

  let requestBody: ConnectWithCodeRequest;
  try {
    if (!event.body) return jsonResponse(400, { error: 'Request body is required' });
    requestBody = JSON.parse(event.body) as ConnectWithCodeRequest;
  } catch {
    return jsonResponse(400, { error: 'Invalid JSON in request body' });
  }

  if (!requestBody.userId || typeof requestBody.userId !== 'string') {
    return jsonResponse(400, { error: 'userId is required and must be a string' });
  }
  if (!requestBody.sharingCode || typeof requestBody.sharingCode !== 'string') {
    return jsonResponse(400, { error: 'sharingCode is required and must be a string' });
  }

  let safeWalkId: string;
  try {
    const result = await docClient.send(
      new GetCommand({ TableName: tableName, Key: { safeWalkAppId: requestBody.userId } }),
    );

    if (!result.Item?.safeWalkId) {
      return jsonResponse(400, { error: 'User has not been registered on the platform yet' });
    }
    safeWalkId = result.Item.safeWalkId as string;
  } catch (error) {
    console.error('Error retrieving user:', error);
    return jsonResponse(500, {
      error: 'Failed to retrieve user data',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }

  const trustedContactsUrl = `${platformBaseDomain}/contacts`;
  const payload: PlatformTrustedContactPayload = {
    requesterSafeWalkId: safeWalkId,
    sharingCode: requestBody.sharingCode,
  };

  try {
    const platformResponse = await sendRequest<PlatformTrustedContactResponse>(
      trustedContactsUrl,
      payload,
      apiKey,
    );

    if (!platformResponse.success) {
      console.error('Platform rejected trusted contact registration:', platformResponse);
      return jsonResponse(502, { error: 'Platform rejected trusted contact registration' });
    }

    console.log('Successfully registered as trusted contact for user:', requestBody.userId);
    return jsonResponse(200, { message: 'Successfully connected as trusted contact' });
  } catch (error) {
    console.error('Error registering as trusted contact:', error);
    return jsonResponse(502, {
      error: 'Failed to register as trusted contact',
      details: error instanceof Error ? error.message : 'Unknown error',
    });
  }
}

// ---------------------------------------------------------------------------
// HTTP helper – mirrors the sendRequest utility in platform-registration-handler
// ---------------------------------------------------------------------------

async function sendRequest<T>(url: string, payload: unknown, apiKey: string): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const data = JSON.stringify(payload);
    const parsedUrl = new URL(url.startsWith('http') ? url : `https://${url}`);
    const isHttps = parsedUrl.protocol === 'https:';
    const httpModule = isHttps ? https : http;

    const options: https.RequestOptions = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port || (isHttps ? 443 : 80),
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
        'x-api-key': apiKey,
      },
    };

    console.log('Sending request to platform:', {
      hostname: options.hostname,
      port: options.port,
      path: options.path,
    });

    const req = httpModule.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => { responseData += chunk; });
      res.on('end', () => {
        console.log('Platform response status:', res.statusCode);
        console.log('Platform response body:', responseData);
        if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(JSON.parse(responseData) as T);
          } catch {
            reject(new Error(`Failed to parse platform response: ${responseData}`));
          }
        } else {
          reject(new Error(`Platform returned status ${res.statusCode}: ${responseData}`));
        }
      });
    });

    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Request timed out')); });
    req.setTimeout(15000);
    req.write(data);
    req.end();
  });
}
