exports.handler = async (event, context) => {
    try {
        const response = {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Hello from the restaurant service!'
            })
        };
        
        return response;
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: 'Internal server error'
            })
        };
    }
}; 