// Lambda entry point
// Configure Lambda handler as: index.handler

const { handler, health } = require("./src/handlers/lambda");

exports.handler = handler;
exports.health = health;
