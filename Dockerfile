FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy source files
COPY . .

# Build the application using Vite
RUN npm run build

# Debug: List what was built
RUN echo "=== Built files ===" && \
    ls -la pages/ && \
    echo "=== Assets directory ===" && \
    ls -la pages/assets/ 2>/dev/null || echo "No assets directory" && \
    echo "=== index.html content (first 100 lines) ===" && \
    head -100 pages/index.html && \
    echo "=== Checking for Task-Checklist references ===" && \
    grep -n "Task-Checklist" pages/index.html || echo "No Task-Checklist references found"

# Production stage
FROM nginx:alpine

# Copy built files directly to nginx html root
COPY --from=build /app/pages /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Debug: List what's in nginx html directory
RUN echo "=== Nginx html directory ===" && \
    ls -la /usr/share/nginx/html/ && \
    echo "=== Assets in nginx ===" && \
    ls -la /usr/share/nginx/html/assets/ 2>/dev/null || echo "No assets in nginx" && \
    echo "=== Checking nginx index.html for Task-Checklist references ===" && \
    grep -n "Task-Checklist" /usr/share/nginx/html/index.html || echo "No Task-Checklist references in nginx html"

# Ensure proper permissions
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]