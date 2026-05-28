# Step 1: Use a clean, lightweight Node.js engine
FROM node:20-alpine

# Step 2: Create a workspace folder inside the container
WORKDIR /usr/src/app

# Step 3: Copy over your library dependencies files
COPY package*.json ./

# Step 4: Install the internal network communication components
RUN npm install --only=production

# Step 5: Copy over your server logic and front-end public folder
COPY server.js ./
COPY public/ ./public/

# Step 6: Expose the operational application port
EXPOSE 8080

# Step 7: Fire up the live engine!
CMD [ "npm", "start" ]