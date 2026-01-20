# User Profile Handler Lambda
## Example Usage

```bash
curl -X POST https://your-api-gateway-url/register \
  -H "Content-Type: application/json" \
  -d '{
    "platformId": "platformA",
    "platformUserId": "user123",
    "email": "user@example.com",
    "name": "Max Muster"
  }'
```
