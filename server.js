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

        // 2. Remove hidden null terminators (\0) that Godot/WebRTC sends
        msgStr = msgStr.replace(/\0/g, '').trim();

        console.log(`[SERVER] Cleaned incoming command: ${msgStr}`);

        // --- COMMAND 1: CREATE ROOM (C:) ---
        if (msgStr.startsWith('C:')) {
            const targetRoom = msgStr.substring(2);

            // Rejection: Prevent overwriting an existing room
            if (lobbies.has(targetRoom)) {
                console.log(`[SERVER REJECT] Room '${targetRoom}' already exists.`);
                ws.send("FULL:Room already exists!");
                return;
            }

            // Create room and set current host
            currentRoom = targetRoom;
            lobbies.set(currentRoom, new Set([ws]));

            console.log(`[SERVER] Peer ${peerId} CREATED room: ${currentRoom}`);
            ws.send("JOINED:");
        }

        // --- COMMAND 2: JOIN ROOM (J:) ---
        else if (msgStr.startsWith('J:')) {
            const targetRoom = msgStr.substring(2);

            // Rejection 1: Room doesn't exist (typed a random/wrong code)
            if (!lobbies.has(targetRoom)) {
                console.log(`[SERVER REJECT] Room '${targetRoom}' does NOT exist.`);
                ws.send("FULL:Room does not exist!");
                return;
            }

            // Rejection 2: Room is already full (2 players maximum)
            if (lobbies.get(targetRoom).size >= 2) {
                console.log(`[SERVER REJECT] Room '${targetRoom}' is FULL.`);
                ws.send("FULL:Room is full!");
                return;
            }

            // Successfully join room
            currentRoom = targetRoom;
            console.log(`[SERVER] Peer ${peerId} JOINED room: ${currentRoom}`);

            ws.send("JOINED:");

            // Notify existing peers in the room about the new player
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) {
                    ws.send(`P:${client.peerId}`);
                }
            });

            lobbies.get(currentRoom).add(ws);
        }

        // --- COMMAND 3: WEBRTC SIGNAL PASS-THROUGH (SDP / ICE candidates) ---
        else if (currentRoom && lobbies.has(currentRoom)) {
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) client.send(msgStr);
            });
        }
    });

    // --- DISCONNECT HANDLER ---
    ws.on('close', () => {
        console.log(`[SERVER] Peer ${peerId} disconnected.`);
        if (currentRoom && lobbies.has(currentRoom)) {
            const roomSet = lobbies.get(currentRoom);

            // Notify remaining players about peer exit
            roomSet.forEach(client => {
                if (client !== ws) client.send(`D:${ws.peerId}`);
            });

            roomSet.delete(ws);

            // Clean up room memory if empty
            if (roomSet.size === 0) {
                console.log(`[SERVER] Room '${currentRoom}' is empty. Deleting...`);
                lobbies.delete(currentRoom);
            }
        }
    });
});

const PORT = process.env.PORT || 9080;
server.listen(PORT, () => {
    console.log(`Signaling server listening on port ${PORT}`);
});