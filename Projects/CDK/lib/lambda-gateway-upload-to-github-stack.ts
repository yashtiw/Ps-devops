import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

export class LambdaGatewayStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const helloLambda = new lambda.Function(this, 'HelloHandler', {
      runtime: lambda.Runtime.NODEJS_18_X,
      code: lambda.Code.fromAsset('lambda'),
      handler: 'index.handler',
      memorySize: 256,
      timeout: cdk.Duration.seconds(10),
    });

    new apigateway.LambdaRestApi(this, 'ApiGateway', {
      handler: helloLambda,
      proxy: true,
      restApiName: 'LambdaGatewayApi',
      description: 'API Gateway endpoint for the Lambda function',
    });
  }
}
