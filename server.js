const express = require('express');
const redis = require('redis');
const path = require('path');

const app = express();
const PORT = 80;

// Connect to the Redis container using its Docker network name
const client = redis.createClient({
    url: 'redis://data-store:6379'
});

client.on('error', (err) => console.log('Redis Client Error', err));

async function startServer() {
    await client.connect();
    
    // Initialize visits counter if it doesn't exist
    const exists = await client.exists('visits');
    if (!exists) {
        await client.set('visits', 0);
    }

    // API Endpoint to get and increment visit count
    app.get('/api/visits', async (req, res) => {
        const visits = await client.incr('visits');
        
        // Sleek server log to track incoming dashboard traffic in real-time
        console.log(`[SERVER LOG] 📥 Request received. Telemetry count updated to: ${visits} | Time: ${new Date().toISOString()}`);
        
        res.json({ count: visits });
    });

    // Serve your static index.html frontend
    app.use(express.static(path.join(__dirname)));

    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
}

startServer();