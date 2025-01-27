const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const parseQuery = (query) => {
    const keywords = {
        style: ['Italian', 'Korean', 'French', 'Japanese', 'Indian'],
        dietary: ['vegetarian'],
        timing: ['all']
    };

    const result = {
        style: null,
        isVegetarian: null,
        includeClosedRestaurants: false
    };

    // Convert query to lowercase for easier matching
    const lowerQuery = query.toLowerCase();

    // Check for cuisine style
    keywords.style.forEach(style => {
        if (lowerQuery.includes(style.toLowerCase())) {
            result.style = style;
        }
    });

    // Check for vegetarian preference
    if (lowerQuery.includes('vegetarian')) {
        result.isVegetarian = 'true';
    }

    // Check if we should include closed restaurants
    if (lowerQuery.includes('all')) {
        result.includeClosedRestaurants = true;
    }

    return result;
};

const isRestaurantOpen = (restaurant) => {
    const now = new Date();
    const currentTime = now.getHours() + ':' + now.getMinutes().toString().padStart(2, '0');
    
    return currentTime >= restaurant.openHour && currentTime <= restaurant.closeHour;
};

exports.handler = async (event, context) => {
    const requestId = context.awsRequestId;
    const timestamp = new Date().toISOString();
    const date = timestamp.split('T')[0];
    let body;
    
    try {
        // Extract query from event body
        body = JSON.parse(event.body || '{}');
        const query = body.query;
        
        if (!query) {
            throw new Error('Query is required');
        }

        // Parse the natural language query
        const parsedQuery = parseQuery(query);

        // Build DynamoDB query
        let params = {
            TableName: process.env.DYNAMODB_TABLE_NAME,
            IndexName: 'StyleIndex',
            KeyConditionExpression: '#s = :style',
            ExpressionAttributeNames: {
                '#s': 'style'
            },
            ExpressionAttributeValues: {
                ':style': parsedQuery.style
            }
        };

        if (parsedQuery.isVegetarian) {
            params.FilterExpression = 'isVegetarian = :isVeg';
            params.ExpressionAttributeValues[':isVeg'] = parsedQuery.isVegetarian;
        }

        const result = await dynamodb.query(params).promise();
        let restaurants = result.Items;
        
        if (!parsedQuery.includeClosedRestaurants) {
            restaurants = restaurants.filter(isRestaurantOpen);
        }

        const responseBody = {
            restaurantRecommendations: restaurants.map(restaurant => ({
                name: restaurant.name,
                style: restaurant.style,
                address: restaurant.address,
                openHour: restaurant.openHour,
                closeHour: restaurant.closeHour,
                vegetarian: restaurant.isVegetarian === 'true'
            }))
        };

        // Write to audit table
        await dynamodb.put({
            TableName: process.env.AUDIT_TABLE_NAME,
            Item: {
                requestId: requestId,
                timestamp: timestamp,
                date: date,
                query: query,
                response: responseBody,
                restaurantsFound: restaurants.length
            }
        }).promise();

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(responseBody)
        };
    } catch (error) {
        // Write error to audit table
        await dynamodb.put({
            TableName: process.env.AUDIT_TABLE_NAME,
            Item: {
                requestId: requestId,
                timestamp: timestamp,
                date: date,
                query: body?.query || 'No query provided',
                error: error.message || 'Unknown error'
            }
        }).promise();

        return {
            statusCode: error.statusCode || 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: error.message || 'Internal server error'
            })
        };
    }
}; 