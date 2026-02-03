# Use official Node.js LTS Alpine image for smaller footprint
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /usr/src/app

# Copy package manifests first (for caching layers)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose the application port
EXPOSE 3000

# Start the application
CMD [ "npm", "start" ]
