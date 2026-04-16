# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage - use a lightweight web server
FROM node:20-alpine

WORKDIR /app

# Install a simple HTTP server to serve static files
RUN npm install -g serve

# Copy built assets from builder stage
COPY --from=builder /app/dist ./dist

# Expose port 8080 (Google Cloud Run default)
EXPOSE 8080

# Set environment to production
ENV NODE_ENV=production

# Serve the application on port 8080
CMD ["serve", "-s", "dist", "-l", "8080"]