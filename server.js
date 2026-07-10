const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: process.env.PORT || 9080 });

const lobbies = new Map(); // room_id -> Set of clients

wss.on('connection', (ws) => {
    let currentRoom = null;
    let peerId = Math.floor(Math.random() * 2147483647);

    ws.on('message', (message) => {
        const msgStr = message.toString();
        
        // Protocol: Join Room (J:room_name)
        if (msgStr.startsWith('J:')) {
            currentRoom = msgStr.substring(2);
            if (!lobbies.has(currentRoom)) lobbies.set(currentRoom, new Set());
            
            // Tell the client their assigned Peer ID
            ws.send(`I:${peerId}`);
            
            // Notify existing peers about this new connection
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) {
                    client.send(`Log: Peer ${peerId} joined`);
                    ws.send(`P:${client.peerId}`); // Handshake discovery
                }
            });
            ws.peerId = peerId;
            lobbies.get(currentRoom).add(ws);
        } 
        // Forwarding signaling data packets (O:, A:, C:)
        else if (currentRoom && lobbies.has(currentRoom)) {
            lobbies.get(currentRoom).forEach(client => {
                if (client !== ws) client.send(msgStr);
            });
        }
    });

    ws.on('close', () => {
        if (currentRoom && lobbies.has(currentRoom)) {
            lobbies.get(currentRoom).delete(ws);
            if (lobbies.get(currentRoom).size === 0) lobbies.delete(currentRoom);
        }
    });
});
console.log(`Signaling server running on port ${process.env.PORT || 9080}`);