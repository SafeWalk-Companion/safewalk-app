import { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, UpdateCommand, GetCommand } from '@aws-sdk/lib-dynamodb';
import * as https from 'https';
import * as http from 'http';

const dynamoClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(dynamoClient);

interface RegisterPlatformRequest {
  userId: string;
}

interface PlatformRegistrationPayload {
  platformUserId: string;
  platformId: string;
}

interface PlatformRegistrationResponse {
  success: boolean;
  data: {
    safeWalkId: string;
    sharingCode: string;
  };
}

export const handler = async (event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const platformDomain = process.env.PLATFORM_DOMAIN + "/register";
  const platformId = process.env.VENDOR_ID;
  const tableName = process.env.TABLE_NAME;  const apiKey = process.env.API_KEY;
  if (!platformDomain) {
    console.error('PLATFORM_DOMAIN environment variable is not set');
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Server configuration error: PLATFORM_DOMAIN not set' }),
    };
  }

  if (!platformId) {
    console.error('VENDOR_ID environment variable is not set');
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Server configuration error: VENDOR_ID not set' }),
    };
  }

  if (!tableName) {
    console.error('TABLE_NAME environment variable is not set');
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Server configuration error: TABLE_NAME not set' }),
    };
  }

  if (!apiKey) {
    console.error('API_KEY environment variable is not set');
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Server configuration error: API_KEY not set' }),
    };
  }

  // Parse the request body
  let requestBody: RegisterPlatformRequest;
  try {
    if (!event.body) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Request body is required' }),
      };
    }
    requestBody = JSON.parse(event.body);
  } catch (error) {
    console.error('Failed to parse request body:', error);
    return {
      statusCode: 400,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Invalid JSON in request body' }),
    };
  }

  // Validate userId
  if (!requestBody.userId || typeof requestBody.userId !== 'string') {
    return {
      statusCode: 400,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'userId is required and must be a string' }),
    };
  }

  // Check if user already has a sharingCode (idempotency)
  try {
    const existingUser = await docClient.send(
      new GetCommand({
        TableName: tableName,
        Key: {
          safeWalkAppId: requestBody.userId,
        },
      })
    );

    if (existingUser.Item?.sharingCode) {
      console.log('User already registered, returning existing sharingCode:', existingUser.Item.sharingCode);
      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: 'User already registered',
          userId: requestBody.userId,
          sharingCode: existingUser.Item.sharingCode,
        }),
      };
    }
  } catch (error) {
    console.error('Error checking existing user:', error);
    // Continue with registration if check fails
  }

  // Prepare the payload for the platform registration request
  const payload: PlatformRegistrationPayload = {
    platformUserId: requestBody.userId,
    platformId: platformId
  };

  try {
    // Send registration request to platform
    const response = await sendPlatformRequest(platformDomain, payload, apiKey) as PlatformRegistrationResponse;
    console.log('Platform registration successful:', response);

    // Validate response structure
    if (!response.success || !response.data) {
      console.error('Invalid platform response: missing success field or data object');
      return {
        statusCode: 502,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          error: 'Invalid platform response',
          details: 'Response missing success field or data object',
        }),
      };
    }

    if (!response.data.safeWalkId || !response.data.sharingCode) {
      console.error('Invalid platform response: missing safeWalkId or sharingCode');
      return {
        statusCode: 502,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          error: 'Invalid platform response',
          details: 'Response missing required fields: safeWalkId or sharingCode',
        }),
      };
    }

    // Store safeWalkId in DynamoDB for the user
    await docClient.send(
      new UpdateCommand({
        TableName: tableName,
        Key: {
          safeWalkAppId: requestBody.userId
        },
        UpdateExpression: 'SET safeWalkId = :safeWalkId, sharingCode = :sharingCode, updatedAt = :updatedAt',
        ExpressionAttributeValues: {
          ':safeWalkId': response.data.safeWalkId,
          ':sharingCode': response.data.sharingCode,
          ':updatedAt': new Date().toISOString(),
        },
      })
    );

    console.log('Successfully stored safeWalkId in database for user:', requestBody.userId);

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: 'Platform registration successful',
        userId: requestBody.userId,
        sharingCode: response.data.sharingCode,
      }),
    };
  } catch (error) {
    console.error('Platform registration failed:', error);
    return {
      statusCode: 502,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        error: 'Failed to register with platform',
        details: error instanceof Error ? error.message : 'Unknown error',
      }),
    };
  }
};

async function sendPlatformRequest(domain: string, payload: PlatformRegistrationPayload, apiKey: string): Promise<PlatformRegistrationResponse> {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(payload);

    // Parse the domain to determine protocol and path
    const url = new URL(domain.startsWith('http') ? domain : `https://${domain}`);
    const isHttps = url.protocol === 'https:';
    const httpModule = isHttps ? https : http;

    const options: https.RequestOptions = {
      hostname: url.hostname,
      port: url.port || (isHttps ? 443 : 80),
      path: url.pathname + url.search,
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
      method: options.method,
    });

    const req = httpModule.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        console.log('Platform response status:', res.statusCode);
        console.log('Platform response body:', responseData);

        if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(JSON.parse(responseData));
          } catch (error) {
            reject(new Error(`Failed to parse platform response: ${responseData}`));
          }
        } else {
          reject(new Error(`Platform returned status ${res.statusCode}: ${responseData}`));
        }
      });
    });

    req.on('error', (error) => {
      console.error('Request error:', error);
      reject(error);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timed out'));
    });

    req.setTimeout(15000); // 15 second timeout
    req.write(data);
    req.end();
  });
}
