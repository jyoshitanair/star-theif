const http = require('http');
const WebSocket = require('ws');

// Create a standard HTTP server so Render's proxy can handle the TLS handshake cleanly
const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Signaling server is running');
});

const wss = new WebSocket.Server({ server });

const lobbies = new Map();

wss.on('connection', (ws) => {
    let currentRoom = null;
    let peerId = Math.floor(Math.random() * 2147483647);
    ws.peerId = peerId; // Save it to the socket right away

    // CRITICAL FIX: Send the ID immediately on connection! 
    // This tells Godot who it is so it can start setting up the mesh.
    ws.send(`I:${peerId}`);
    console.log(`[SERVER] User connected. Assigned Peer ID: ${peerId}`);

    ws.on('message', (message) => {
        const msgStr = message.toString();
        console.log(`[SERVER] Received message: ${msgStr}`);
        
        if (msgStr.startsWith('J:')) {
            currentRoom = msgStr.substring(2);
            if (!lobbies.has(currentRoom)) lobbies.set(currentRoom, new Set());
            
            console.log(`[SERVER] Peer ${peerId} is joining room: ${currentRoom}`);
            
            // Tell this new user about all the existing peers already in the room
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) {
                    ws.send(`P:${client.peerId}`);
                }
            });
            
            lobbies.get(currentRoom).add(ws);
        } 
        else if (currentRoom && lobbies.has(currentRoom)) {
            // Forward signaling packets (offers, answers, ice candidates) to everyone else in the room
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) client.send(msgStr);
            });
        }
    });

    ws.on('close', () => {
        console.log(`[SERVER] Peer ${peerId} disconnected.`);
        if (currentRoom && lobbies.has(currentRoom)) {
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) client.send(`D:${ws.peerId}`);
            });
            lobbies.get(currentRoom).delete(ws);
            if (lobbies.get(currentRoom).size === 0) lobbies.delete(currentRoom);
        }
    });
});

// Bind to the port Render gives us
const PORT = process.env.PORT || 9080;
server.listen(PORT, () => {
    console.log(`Signaling server listening on port ${PORT}`);
});