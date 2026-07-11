extends Node

var peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var client: WebSocketPeer = WebSocketPeer.new()

const SIGNAL_URL = "wss://star-theif.onrender.com" 

var current_room_id: String = ""
var is_connecting: bool = false
var last_logged_state: int = -1

func _ready() -> void:
	print("[DEBUG] Network node ready. Base URL: ", SIGNAL_URL)
	set_process(true)

func connect_to_match(room_name: String) -> void:
	if is_connecting or client.get_ready_state() == WebSocketPeer.STATE_OPEN:
		print("[DEBUG] connect_to_match ignored: Connection is already active.")
		return

	current_room_id = room_name.strip_edges()
	print("[DEBUG] connect_to_match called. Room Target: '", current_room_id, "'")
	
	if current_room_id == "":
		print("[ERROR] Cannot connect! Room name parameter is empty.")
		return
		
	client.supported_protocols = PackedStringArray([])
	client.handshake_headers = PackedStringArray([])
	
	print("[DEBUG] Initiating connection to URL...")
	var err = client.connect_to_url(SIGNAL_URL)
	
	if err != OK:
		print("[ERROR] connect_to_url failed instantly: ", err)
	else:
		is_connecting = true
		last_logged_state = -1
		print("[DEBUG] connect_to_url reports OK. Engine state loop started.")

func _process(_delta: float) -> void:
	if not is_connecting:
		return

	client.poll()
	peer.poll()
	
	var state = client.get_ready_state()
	
	if state != last_logged_state:
		_print_state_name(state)
		last_logged_state = state
	
	if state == WebSocketPeer.STATE_OPEN:
		while client.get_available_packet_count() > 0:
			var raw_bytes: PackedByteArray = client.get_packet()
			
			# SAFE FIX: Find where actual text ends before any trailing null terminators
			var end_index = raw_bytes.size()
			while end_index > 0 and raw_bytes[end_index - 1] == 0:
				end_index -= 1
				
			# Slice cleanly to avoid Emscripten size bugs
			if end_index < raw_bytes.size():
				raw_bytes = raw_bytes.slice(0, end_index)
				
			var msg: String = raw_bytes.get_string_from_utf8().strip_edges()
			
			if msg != "":
				_handle_signaling(msg)
				
	elif state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
		var code = client.get_close_code()
		var reason = client.get_close_reason()
		print("[DISCONNECT] Connection closed. Code: ", code, " | Reason: '", reason, "'")
		is_connecting = false 

func _print_state_name(state_id: int) -> void:
	match state_id:
		0: print("[STATE CHANGE] STATE_CONNECTING (0) - Browser is building the socket...")
		1: print("[STATE CHANGE] STATE_OPEN (1) - Handshake complete! Connected to Render.")
		2: print("[STATE CHANGE] STATE_CLOSING (2) - Socket is tearing down...")
		3: print("[STATE CHANGE] STATE_CLOSED (3) - Socket is dead or was rejected.")

func _handle_signaling(msg: String) -> void:
	
	if msg.begins_with("I:"): 
		var my_id = msg.get_slice(":", 1).to_int()
		print("[SIGNAL] Identity received. Assigned ID: ", my_id)
		
		print("[SIGNAL] Sending Join request for room: ", current_room_id)
		client.send_text("J:" + current_room_id)
		
		print("[SIGNAL] Creating WebRTC Mesh...")
		
		# FIX: Godot 4 expects an array of TransferMode integers here.
		# 2 = TRANSFER_MODE_RELIABLE
		# 0 = TRANSFER_MODE_UNRELIABLE
		peer.create_mesh(my_id, [2, 0])
		
		multiplayer.multiplayer_peer = peer
		
		if not multiplayer.peer_connected.is_connected(_player_joined):
			multiplayer.peer_connected.connect(_player_joined)
			
		if not multiplayer.peer_disconnected.is_connected(_player_left):
			multiplayer.peer_disconnected.connect(_player_left)
		
	elif msg.begins_with("JOINED:"):
		print("[NETWORK] Server approved room entry! Redirecting to gameplay scene...")
		get_tree().change_scene_to_file("res://scenes/multiplayertest.tscn")

	elif msg.begins_with("FULL:"):
		var error_reason = msg.get_slice(":", 1)
		print("[NETWORK REJECTION] Cannot join room: ", error_reason)
		
		client.close()
		multiplayer.multiplayer_peer = null
		is_connecting = false
		get_tree().change_scene_to_file("res://scenes/loading.tscn")
	elif msg.begins_with("D:"):
		var peer_id = msg.get_slice(":", 1).to_int()
		print("[SIGNAL] Peer disconnected from signaler: ", peer_id)
		if peer.has_peer(peer_id):
			peer.remove_peer(peer_id)
	elif msg.begins_with("P:"):
		var peer_id = msg.get_slice(":", 1).to_int()
		print("[SIGNAL] New peer discovered in room! Registering ID: ", peer_id)
		
		# FIX: Use the specific extension variant that Web/HTML5 exports require
		var rtc_peer
		if OS.has_feature("web"):
			rtc_peer = ClassDB.instantiate("WebRTCPeerConnectionExtension")
		else:
			rtc_peer = WebRTCPeerConnection.new()
		
		peer.add_peer(rtc_peer, peer_id) 
		
		var connection = peer.get_peer(peer_id)["connection"]
		connection.session_description_created.connect(_on_session_description_created.bind(peer_id))
		connection.ice_candidate_created.connect(_on_ice_candidate_created.bind(peer_id))
		
		connection.create_offer()

	# Inside your _handle_signaling() 'else' block:
	else:
		var json = JSON.new()
		if json.parse(msg) == OK:
			var data = json.get_data()
			
			# CRITICAL: This is the sender's network ID!
			var sender_id = data.get("peer_id", 0) 
			
			if sender_id == 0: return # Safety check
			
			# If we don't track this sender yet, add them to our mesh
			if not peer.has_peer(sender_id):
				var rtc_peer = WebRTCPeerConnection.new()
				peer.add_peer(rtc_peer, sender_id)
				
				var connection = peer.get_peer(sender_id)["connection"]
				connection.session_description_created.connect(_on_session_description_created.bind(sender_id))
				connection.ice_candidate_created.connect(_on_ice_candidate_created.bind(sender_id))
			
			var connection = peer.get_peer(sender_id)["connection"]
			
			if data.type == "candidate":
				connection.add_ice_candidate(data.media, data.index, data.name)
			else:
				# This handles "offer" from P1 -> P2, AND "answer" from P2 -> P1!
				connection.set_remote_description(data.type, data.sdp)
func _on_session_description_created(type: String, sdp: String, peer_id: int) -> void:
	var connection = peer.get_peer(peer_id)["connection"]
	connection.set_local_description(type, sdp)
	
	# Create a payload to send over your WebSocket/Render signaling server
	var payload = {
		"peer_id": multiplayer.get_unique_id(), # MY ID, so they know who sent it
		"type": type,
		"sdp": sdp
	}
	
	# Send it to the server targeted at the other peer
	# Make sure your signaling server wraps this and sends it directly to peer_id!
	client.send_text(JSON.stringify(payload))

func _on_ice_candidate_created(media: String, index: int, name: String, peer_id: int) -> void:
	var payload = {
		"peer_id": multiplayer.get_unique_id(),
		"type": "candidate",
		"media": media,
		"index": index,
		"name": name
	}
	client.send_text(JSON.stringify(payload))

func _player_joined(id: int) -> void:
	print("[MULTIPLAYER] Remote peer successfully linked into mesh! Peer ID: ", id)

func _player_left(id: int) -> void:
	print("[MULTIPLAYER] Peer left. Peer ID: ", id)
