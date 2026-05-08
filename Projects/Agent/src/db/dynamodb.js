const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

// AWS Lambda uses IAM role credentials automatically
const clientConfig = {
  region: process.env.AWS_REGION || "us-east-1"
};

const client = new DynamoDBClient(clientConfig);
const ddbDocClient = DynamoDBDocumentClient.from(client);

async function getNextId(tableName) {
  const command = new UpdateCommand({
    TableName: tableName,
    Key: { uuid: "SEQ" },
    UpdateExpression: "SET #seq = if_not_exists(#seq, :zero) + :inc",
    ExpressionAttributeNames: { "#seq": "seq" },
    ExpressionAttributeValues: { ":zero": 0, ":inc": 1 },
    ReturnValues: "UPDATED_NEW"
  });

  const result = await ddbDocClient.send(command);
  const seqValue = result.Attributes?.seq;
  if (typeof seqValue !== "number") {
    throw new Error("Failed to generate incremental id");
  }
  return String(seqValue);
}

async function putItem(tableName, item) {
  const command = new PutCommand({ TableName: tableName, Item: item });
  return ddbDocClient.send(command);
}

module.exports = { getNextId, putItem };
