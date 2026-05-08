const { getNextId, putItem } = require("../db/dynamodb");

const TABLE_NAME = process.env.DYNAMO_TABLE_NAME;

const validateInput = (agentName, userName, status, subStatus, time) => {
  return (
    typeof agentName === "string" && agentName.trim() &&
    typeof userName === "string" && userName.trim() &&
    typeof status === "string" && status.trim() &&
    typeof subStatus === "string" && subStatus.trim() &&
    typeof time === "string" && time.trim()
  );
};

exports.handler = async (event) => {
  try {
    // Parse the request body - handle both API Gateway and direct Lambda invocation
    let body;
    if (typeof event.body === "string") {
      // API Gateway sends body as JSON string
      body = JSON.parse(event.body);
    } else if (typeof event.body === "object" && event.body !== null) {
      // Direct Lambda invocation with parsed body
      body = event.body;
    } else {
      // Direct Lambda invocation - data is in event root
      body = event;
    }

    const { agentName, userName, status, subStatus, time } = body;

    // Validate required fields
    if (!validateInput(agentName, userName, status, subStatus, time)) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          error: "Request body must include agentName, userName, status, subStatus, and time as non-empty strings."
        })
      };
    }

    const itemId = await getNextId(TABLE_NAME);
    const item = {
      uuid: itemId,
      agentName: agentName.trim(),
      userName: userName.trim(),
      status: status.trim(),
      subStatus: subStatus.trim(),
      time: time.trim(),
      createdAt: new Date().toISOString()
    };

    await putItem(TABLE_NAME, item);

    return {
      statusCode: 201,
      body: JSON.stringify({
        tableName: TABLE_NAME,
        item
      })
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error: "Failed to store item in DynamoDB.",
        details: error instanceof Error ? error.message : String(error)
      })
    };
  }
};

exports.health = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({ status: "ok" })
  };
};
