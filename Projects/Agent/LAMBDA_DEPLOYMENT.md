# DynamoDB Lambda Agent

AWS Lambda handler for storing agent data to DynamoDB.

## Project Structure

```
Agent/
├── index.js                   ← Lambda entry point
├── src/
│   ├── handlers/
│   │   └── lambda.js         # Lambda handler with exports.handler
│   └── db/
│       └── dynamodb.js       # DynamoDB operations
├── package.json
├── .env
└── .env.example
```

## Features

- **Lambda Handler**: `exports.handler` for AWS Lambda
- **5 Input Parameters**: agentName, userName, status, subStatus, time
- **Auto-Incremental ID**: Sequential IDs via DynamoDB
- **IAM Role Authentication**: Uses Lambda execution role credentials

## AWS Lambda Setup

### 1. Create IAM Execution Role

1. Go to **IAM → Roles → Create role**
2. Select **Lambda** as service
3. Attach policy: **AmazonDynamoDBFullAccess** (or custom policy for your table)
4. Note the role ARN

### 2. Package for Lambda

```bash
cd /Users/ytiwari/Downloads/work/Agent
npm install --production
zip -r lambda.zip . -x "node_modules/.bin/*"
```

### 3. Create Lambda Function

1. Go to **AWS Lambda Console → Create function**
2. **Function name**: `agent-data-store`
3. **Runtime**: Node.js 18.x (or later)
4. **Execution role**: Select the role from step 1
5. **Upload code**: Upload `lambda.zip`

### 4. Configure Lambda

- **Handler**: `index.handler`
- **Timeout**: 30 seconds (or adjust as needed)
- **Memory**: 256 MB (or adjust as needed)

### 5. Set Environment Variables

1. Go to **Configuration → Environment variables**
2. Add:
   ```
   DYNAMO_TABLE_NAME=variant_data_qa
   AWS_REGION=us-central-1
   ```

**No AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY needed — Lambda uses IAM role.**

### 6. Create API Gateway (Optional)

1. Go to **API Gateway → Create API → REST API**
2. Create method: **POST /store**
3. Integration: **Lambda Function** → Select `agent-data-store`
4. Deploy

## Request/Response

### POST /store

**Request:**
```json
{
  "agentName": "agent1",
  "userName": "user1",
  "status": "active",
  "subStatus": "pending",
  "time": "2026-05-05T12:34:56Z"
}
```

**Response (201):**
```json
{
  "tableName": "variant_data_qa",
  "item": {
    "uuid": "1",
    "agentName": "agent1",
    "userName": "user1",
    "status": "active",
    "subStatus": "pending",
    "time": "2026-05-05T12:34:56Z",
    "createdAt": "2026-05-05T12:34:56.123Z"
  }
}
```

**Response (400 - Invalid Input):**
```json
{
  "error": "Request body must include agentName, userName, status, subStatus, and time as non-empty strings."
}
```

## DynamoDB Table

**Table Name**: `variant_data_qa`
**Partition Key**: `uuid` (String)

**Items Schema:**
- `uuid` (String) - Auto-incremental, Partition Key
- `agentName` (String)
- `userName` (String)
- `status` (String)
- `subStatus` (String)
- `time` (String)
- `createdAt` (String) - ISO timestamp

**Counter Item**: Special item with `uuid = "SEQ"` for auto-increment

## Testing

### Test via AWS Lambda Console

1. Go to **Function → Test**
2. Create test event:
```json
{
  "body": "{\"agentName\": \"test\", \"userName\": \"user1\", \"status\": \"active\", \"subStatus\": \"pending\", \"time\": \"2026-05-05T12:34:56Z\"}"
}
```
3. Click **Test** and check response

### Test via curl

```bash
curl -X POST https://YOUR_API_GATEWAY_URL/store \
  -H "Content-Type: application/json" \
  -d '{
    "agentName": "agent1",
    "userName": "user1",
    "status": "active",
    "subStatus": "pending",
    "time": "2026-05-05T12:34:56Z"
  }'
```

## Files

### `index.js`
Lambda entry point that re-exports handlers

### `src/handlers/lambda.js`
Lambda handler with `exports.handler` and `exports.health`

**Exports:**
- `handler(event)` - Main handler for storing data
- `health(event)` - Health check endpoint

### `src/db/dynamodb.js`
DynamoDB operations

**Exports:**
- `getNextId(tableName)` - Get next sequential ID
- `putItem(tableName, item)` - Store item

## Troubleshooting

### Permission Denied Error
Verify Lambda execution role has DynamoDB permissions:
- IAM → Roles → Select role → Check attached policies

### Table Not Found
Verify `DYNAMO_TABLE_NAME` matches actual table name

### Timeout Error
Increase Lambda timeout in Configuration

## License

MIT
