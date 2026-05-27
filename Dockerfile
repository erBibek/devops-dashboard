# --- STAGE 1: The Builder ---
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./
# Install ALL dependencies (including dev tools if needed)
RUN npm install

COPY . .

# --- STAGE 2: The Final Production Image ---
FROM node:18-alpine AS runner

WORKDIR /usr/src/app

# Copy ONLY the package files and the lightweight production modules from Stage 1
COPY package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/server.js ./server.js
COPY --from=builder /usr/src/app/index.html ./index.html

# Expose the production port
EXPOSE 80

# Keep the image secure by running as a non-root user (built into node alpine)
USER node

CMD [ "node", "server.js" ]