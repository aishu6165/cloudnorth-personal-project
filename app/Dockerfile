# Use slim Alpine image, smaller attack surface, faster pulls from ECR
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy dependency files first, Docker caches this layer
# so npm install only reruns when package.json changes
COPY package*.json ./
RUN npm install --production

# Copy app source
COPY app.js .

# App runs on 8080, must match ALB target group port and security group rule
EXPOSE 8080

# Run as non-root user, security best practice
USER node

CMD ["node", "app.js"]
