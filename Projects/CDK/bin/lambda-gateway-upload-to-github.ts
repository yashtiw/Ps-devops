#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { LambdaGatewayStack } from '../lib/lambda-gateway-upload-to-github-stack';

const app = new cdk.App();
new LambdaGatewayStack(app, 'LambdaGatewayStack');
