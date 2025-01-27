# Use AWS Lambda base image for Node.js
FROM public.ecr.aws/lambda/nodejs:18

# Set working directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY . .

# Set the CMD to your handler
CMD [ "restaurant.handler" ]
