# Platform Registration Handler Lambda

Lambda function that sends platform registration requests to external platforms and stores the returned `safeWalkId` in the database.

## Environment Variables

- `PLATFORM_DOMAIN`: The host of the SafeWalk platform (e.g., `https://platform.example.com`)
- `VENDOR_ID`: Your vendor identification ID for the platform
- `API_KEY`: The API key for authenticating with the platform (sent as `x-api-key` header)

## How It Works

1. Receives a `userId` from the API request
2. Checks if there is already a sharingCode associated with the given `userId`
3. Sends a POST request to the platform with `userId`, `vendorId`, and `timestamp`
4. Expects a JSON response from the platform containing `safeWalkId` and `sharingCode`
5. Stores the `safeWalkId` and `sharingCode` in the DynamoDB table for the user
6. Returns the `sharingCode` to the client

## Example Usage

```bash
curl -X POST https://your-api-gateway-url/register/platform \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "123456"
  }'
```

## Expected Platform Response

The external platform should return:
```json
{
  "success": true,
  "data": {
    "safeWalkId": "12345678-1234-1234-1234-1234abcd1234",
    "sharingCode": "ABCDEF"
  }
}
```

## Response

Success (200):
```json
{
  "message": "Platform registration successful",
  "userId": "123456",
  "sharingCode": "ABCDEF"
}
```

Error (400 - Bad Request):
```json
{
  "error": "userId is required and must be a string"
}
```

Error (500 - Server Configuration):
```json
{
  "error": "Server configuration error: PLATFORM_DOMAIN not set"
}
```

Error (502 - Platform Error):
```json
{
  "error": "Failed to register with platform",
  "details": "Error details..."
}
```
