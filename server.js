const http = require('http');
const WebSocket = require('ws');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Signaling server is running');
});

const wss = new WebSocket.Server({ server });
const lobbies = new Map();

wss.on('connection', (ws) => {
    let currentRoom = null;
    let peerId = Math.floor(Math.random() * 2147483647);
    ws.peerId = peerId;

    ws.send(`I:${peerId}`);
    console.log(`[SERVER] User connected. Assigned Peer ID: ${peerId}`);
    ws.on('message', (message) => {
    // 1. Convert to string
    let msgStr = typeof message === 'string' ? message : message.toString('utf8');
    
    // 2. CRITICAL: Remove hidden null terminators (\0) that Godot sends!
    msgStr = msgStr.replace(/\0/g, '').trim();

    console.log(`[SERVER] Cleaned incoming command: ${msgStr}`);

    if (msgStr.startsWith('J:')) {
        const targetRoom = msgStr.substring(2);
        
        if (lobbies.has(targetRoom) && lobbies.get(targetRoom).size >= 2) {
            console.log(`[SERVER] Room '${targetRoom}' is FULL.`);
            ws.send("FULL:Room is full!");
            return;
        }

        currentRoom = targetRoom;
        if (!lobbies.has(currentRoom)) {
            lobbies.set(currentRoom, new Set());
        }

        console.log(`[SERVER] Peer ${peerId} successfully joined room: ${currentRoom}`);
        
        // Send permission back
        ws.send("JOINED:");

        lobbies.get(currentRoom).forEach(client => {
            if (client !== ws) {
                ws.send(`P:${client.peerId}`);
            }
        });

        lobbies.get(currentRoom).add(ws);
    }
    else if (currentRoom && lobbies.has(currentRoom)) {
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

const PORT = process.env.PORT || 9080;
server.listen(PORT, () => {
    console.log(`Signaling server listening on port ${PORT}`);
});