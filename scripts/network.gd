extends Node

var peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var client: WebSocketPeer = WebSocketPeer.new()

const SIGNAL_URL = "wss://star-theif.onrender.com" 

var current_room_id: String = ""
var is_connecting: bool = false
var last_logged_state: int = -1
var is_host: bool = false

# messages! 

var error = ""

# Kept as an Array as requested!
const ALLOWED_CHARS: Array[String] = [
	"A","B","C","D","E","F","G","H","J","K","L","M",
	"N","P","Q","R","S","T","U","V","W","X","Y","Z",
	"2","3","4","5","6","7","8","9"
]

func _ready() -> void:
	print("[DEBUG] Network node ready. Base URL: ", SIGNAL_URL)
	set_process(true)

# --- PUBLIC INTERFACE FUNCTIONS ---

## Call this to generate a code, create a room, and connect!
func create_room() -> String:
	is_host = true
	var new_code = generate_room_code(6)
	connect_to_match(new_code)
	return new_code

## Call this to join an existing room code!
func join_room(room_code: String) -> void:
	var cleaned_code = room_code.strip_edges().to_upper()
	
	# Rule 1: Check length (must be 6 characters)
	if cleaned_code.length() != 6:
		error = "Cannot join: Room code must be exactly 6 characters!"
		print("[ERROR] Cannot join: Room code must be exactly 6 characters!")
		return
		
	# Rule 2: Ensure every character belongs to ALLOWED_CHARS array
	for i in range(cleaned_code.length()):
		var char_letter = String(cleaned_code[i])
		if not ALLOWED_CHARS.has(char_letter):
			error = "Cannot join: Code contains invalid character '"+ char_letter+ "'"
			print("[ERROR] Cannot join: Code contains invalid character '", char_letter, "'")
			return
			
	is_host = false
	connect_to_match(cleaned_code)

## Internal connection handler
func connect_to_match(room_name: String) -> void:
	if is_connecting or client.get_ready_state() == WebSocketPeer.STATE_OPEN:
		print("[DEBUG] connect_to_match ignored: Connection is already active.")
		return

	current_room_id = room_name.strip_edges().to_upper()
	print("[DEBUG] connect_to_match called. Target Room: '", current_room_id, "' | Is Host: ", is_host)
	
	if current_room_id == "":
		error = "Cannot connect! Room name parameter is empty."
		print("[ERROR] Cannot connect! Room name parameter is empty.")
		return
		
	client.supported_protocols = PackedStringArray([])
	client.handshake_headers = PackedStringArray([])
	
	print("[DEBUG] Initiating connection to URL...")
	var err = client.connect_to_url(SIGNAL_URL)
	
	if err != OK:
		error = "connect_to_url failed instantly: "+ err
		print("[ERROR] connect_to_url failed instantly: ", err)
	else:
		is_connecting = true
		last_logged_state = -1
		print("[DEBUG] connect_to_url reports OK. Engine state loop started.")

# --- NETWORK LOOP ---

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
			
			# SAFE FIX: Find where actual text ends before trailing null terminators
			var end_index = raw_bytes.size()
			while end_index > 0 and raw_bytes[end_index - 1] == 0:
				end_index -= 1
				
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
		0: print("[STATE CHANGE] STATE_CONNECTING (0) - Building socket...")
		1: print("[STATE CHANGE] STATE_OPEN (1) - Handshake complete!")
		2: print("[STATE CHANGE] STATE_CLOSING (2) - Socket closing...")
		3: print("[STATE CHANGE] STATE_CLOSED (3) - Socket closed or rejected.")

# --- SIGNALING HANDLER ---

func _handle_signaling(msg: String) -> void:
	if msg.begins_with("I:"): 
		var my_id = msg.get_slice(":", 1).to_int()
		print("[SIGNAL] Identity received. Assigned ID: ", my_id)
		
		# Send "C:" for Create, or "J:" for Join
		var prefix = "C:" if is_host else "J:"
		print("[SIGNAL] Sending request: ", prefix + current_room_id)
		client.send_text(prefix + current_room_id)
		
		print("[SIGNAL] Creating WebRTC Mesh...")
		peer.create_mesh(my_id, [2, 0])
		multiplayer.multiplayer_peer = peer
		
		if not multiplayer.peer_connected.is_connected(_player_joined):
			multiplayer.peer_connected.connect(_player_joined)
			
		if not multiplayer.peer_disconnected.is_connected(_player_left):
			multiplayer.peer_disconnected.connect(_player_left)
		
	elif msg.begins_with("JOINED:"):
		print("[NETWORK] Server approved room entry! Redirecting to gameplay scene...")
		get_tree().change_scene_to_file("res://scenes/multiplayertest.tscn")

	elif msg.begins_with("FULL:") or msg.begins_with("ERROR:"):
		var error_reason = msg.get_slice(":", 1)
		print("[NETWORK REJECTION] Cannot enter room: ", error_reason)
		
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
		
		var rtc_peer = _create_rtc_peer()
		peer.add_peer(rtc_peer, peer_id) 
		
		var connection = peer.get_peer(peer_id)["connection"]
		connection.session_description_created.connect(_on_session_description_created.bind(peer_id))
		connection.ice_candidate_created.connect(_on_ice_candidate_created.bind(peer_id))
		
		connection.create_offer()

	else:
		var json = JSON.new()
		if json.parse(msg) == OK:
			var data = json.get_data()
			var sender_id = data.get("peer_id", 0) 
			
			if sender_id == 0: return
			
			if not peer.has_peer(sender_id):
				var rtc_peer = _create_rtc_peer()
				peer.add_peer(rtc_peer, sender_id)
				
				var connection = peer.get_peer(sender_id)["connection"]
				connection.session_description_created.connect(_on_session_description_created.bind(sender_id))
				connection.ice_candidate_created.connect(_on_ice_candidate_created.bind(sender_id))
			
			var connection = peer.get_peer(sender_id)["connection"]
			
			if data.type == "candidate":
				connection.add_ice_candidate(data.media, data.index, data.name)
			else:
				connection.set_remote_description(data.type, data.sdp)

# --- WEBRTC CALLBACKS ---

func _create_rtc_peer():
	if OS.has_feature("web"):
		return ClassDB.instantiate("WebRTCPeerConnectionExtension")
	return WebRTCPeerConnection.new()

func _on_session_description_created(type: String, sdp: String, peer_id: int) -> void:
	var connection = peer.get_peer(peer_id)["connection"]
	connection.set_local_description(type, sdp)
	
	var payload = {
		"peer_id": multiplayer.get_unique_id(),
		"type": type,
		"sdp": sdp
	}
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

# --- HELPER CODE GENERATOR ---

func generate_room_code(length: int = 6) -> String:
	randomize()
	var code: String = ""
	var array_size: int = ALLOWED_CHARS.size()
	
	for i in range(length):
		code += ALLOWED_CHARS[randi() % array_size]
		
	return code
