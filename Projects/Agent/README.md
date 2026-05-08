# DynamoDB API Agent

A Node.js application for storing agent data to AWS DynamoDB via both Express API and AWS Lambda.

## Project Structure

```
Agent/
├── src/
│   ├── handlers/
│   │   ├── api.mjs         # Express server for local development
│   │   └── lambda.mjs      # AWS Lambda handler for API Gateway
│   └── db/
│       └── ddb.mjs         # DynamoDB operations (getNextId, putItem)
├── package.json            # Dependencies and scripts
├── .env                    # Environment variables (local)
├── .env.example            # Example env file
└── README.md               # This file
```

## Features

- **5 Input Parameters**: `agentName`, `userName`, `status`, `subStatus`, `time`
- **Auto-Incremental ID**: Sequential IDs stored in DynamoDB
- **Dual Support**: Express API for local testing + Lambda for production
- **DynamoDB Integration**: Stores data with timestamps
- **AWS Credentials**: Uses IAM role on Lambda, explicit keys for local dev

## Installation

```bash
cd /Users/ytiwari/Downloads/work/Agent
npm install
```

## Configuration

Create `.env` file from `.env.example`:

```
DYNAMO_TABLE_NAME=variant_data_qa
AWS_REGION=us-central-1
# Only needed for local development
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
PORT=3000
```

## Running Locally (Express)

```bash
npm start
```

Server runs on `http://localhost:3000`

### Health Check
```bash
curl http://localhost:3000/health
```

### Store Data
```bash
curl -X POST http://localhost:3000/store \
  -H "Content-Type: application/json" \
  -d '{
    "agentName": "agent1",
    "userName": "user1",
    "status": "active",
    "subStatus": "pending",
    "time": "2026-05-05T12:34:56Z"
  }'
```

## AWS Lambda Deployment

### 1. Package for Lambda
```bash
npm install --production
zip -r lambda.zip . -x "node_modules/.bin/*"
```

### 2. Create Lambda Function
- **Runtime**: Node.js 18.x or later
- **Handler**: `src/handlers/lambda.storeData`
- **Upload**: `lambda.zip`

### 3. Set Lambda Environment Variables
```
DYNAMO_TABLE_NAME=variant_data_qa
AWS_REGION=us-central-1
```

**No need for `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` — Lambda uses IAM role credentials.**

### 4. Set Up IAM Execution Role
1. Go to IAM → Roles
2. Create role with "Lambda" service
3. Attach policy: **AmazonDynamoDBFullAccess** or custom policy
4. Attach to Lambda function

### 5. Create API Gateway (Optional)
- Method: POST
- Path: `/store`
- Integration: Lambda `src/handlers/lambda.storeData`

## API Endpoints

### POST `/store`
Stores data to DynamoDB

**Request:**
```json
{
  "agentName": "string",
  "userName": "string",
  "status": "string",
  "subStatus": "string",
  "time": "string (ISO format)"
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

### GET `/health`
Health check endpoint

**Response:**
```json
{
  "status": "ok"
}
```

## DynamoDB Table Schema

**Table Name:** `variant_data_qa`

**Partition Key:** `uuid` (String)

**Items stored:**
- `uuid` (String) - Auto-incremental, Partition Key
- `agentName` (String)
- `userName` (String)
- `status` (String)
- `subStatus` (String)
- `time` (String)
- `createdAt` (String) - ISO timestamp

**Counter Item:**
- Special item with `uuid = "SEQ"` for auto-increment counter

## File Reference

### `src/db/ddb.mjs`
DynamoDB operations module

**Exports:**
- `getNextId(tableName)` - Get next sequential ID
- `putItem(tableName, item)` - Store item in DynamoDB

### `src/handlers/api.mjs`
Express server for local development

**Routes:**
- `POST /store` - Store data
- `GET /health` - Health check

### `src/handlers/lambda.mjs`
AWS Lambda handlers for API Gateway

**Exports:**
- `storeData(event)` - Store data (Lambda)
- `health(event)` - Health check (Lambda)

## Troubleshooting

### Credentials Error on Local
Ensure `.env` has `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` set

### Lambda Credentials Error
Make sure Lambda execution role has DynamoDB permissions attached

### Table Not Found Error
Verify `DYNAMO_TABLE_NAME` in environment variables matches actual DynamoDB table name

## License

MIT
