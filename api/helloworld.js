const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    console.log('Context:', JSON.stringify(context, null, 2));
    console.log('Environment variables:', {
        DYNAMODB_TABLE_NAME: process.env.DYNAMODB_TABLE_NAME,
        AWS_REGION: process.env.AWS_REGION
    });

    try {
        const params = {
            TableName: process.env.DYNAMODB_TABLE_NAME,
            IndexName: 'StyleIndex',
            KeyConditionExpression: '#s = :style',
            ExpressionAttributeNames: {
                '#s': 'style'
            },
            ExpressionAttributeValues: {
                ':style': 'Italian'
            },
            Limit: 1
        };

        console.log('DynamoDB Query params:', JSON.stringify(params, null, 2));

        const result = await dynamodb.query(params).promise();
        console.log('DynamoDB Query result:', JSON.stringify(result, null, 2));
        
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Hello from the restaurant service!',
                restaurant: result.Items[0] || null
            })
        };
        
        console.log('Response:', JSON.stringify(response, null, 2));
        return response;
    } catch (error) {
        console.error('Error:', {
            message: error.message,
            stack: error.stack,
            code: error.code,
            statusCode: error.statusCode,
            requestId: error.requestId
        });
        
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Internal server error',
                error: error.message
            })
        };
    }
}; 