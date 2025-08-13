# ---- build stage ----
FROM node:20-alpine AS builder
WORKDIR /app

# Install deps first for better caching
COPY package*.json ./
RUN npm ci

# Copy the rest and build
COPY . .
# If you have env vars needed at build time, pass them as --build-arg or .env.production
RUN npm run build

# ---- run stage ----
FROM nginx:alpine
# Nginx config for SPA routing (history fallback to index.html)
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy the Vite build output from pages directory
COPY --from=builder /app/pages /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
