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
	current_room_id = room_name.strip_edges()
	print("[DEBUG] connect_to_match called. Room Target: '", current_room_id, "'")
	
	if current_room_id == "":
		print("[ERROR] Cannot connect! Room name parameter is empty.")
		return
		
	# Wipe default headers/protocols
	client.supported_protocols = PackedStringArray([])
	client.handshake_headers = PackedStringArray([])
	
	print("[DEBUG] Initiating connection to URL...")
	var err = client.connect_to_url(SIGNAL_URL)
	
	if err != OK:
		print("[ERROR] connect_to_url failed instantly with internal Godot error code: ", err)
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
	
	# Only print the state changes so we don't spam the log 60 times a second
	if state != last_logged_state:
		_print_state_name(state)
		last_logged_state = state
	
	if state == WebSocketPeer.STATE_OPEN:
		var packet_count = client.get_available_packet_count()
		if packet_count > 0:
			print("[DEBUG] Packets available to read: ", packet_count)
		
		while client.get_available_packet_count() > 0:
			var msg = client.get_packet().get_string_from_utf8()
			print("[INBOUND PACKET]: ", msg)
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
		_: print("[STATE CHANGE] Unknown State ID: ", state_id)

func _handle_signaling(msg: String) -> void:
	if msg.begins_with("I:"): 
		var my_id = msg.get_slice(":", 1).to_int()
		print("[SIGNAL] Identity received. Assigned ID: ", my_id)
		
		print("[SIGNAL] Sending Join request for room: ", current_room_id)
		client.send_text("J:" + current_room_id)
		
		print("[SIGNAL] Creating WebRTC Mesh...")
		peer.create_mesh(my_id)
		multiplayer.multiplayer_peer = peer
		
		multiplayer.peer_connected.connect(_player_joined)
		multiplayer.peer_disconnected.connect(_player_left)

func _player_joined(id: int) -> void:
	print("[MULTIPLAYER] Remote peer connected into mesh! Peer ID: ", id)
	if multiplayer.is_multiplayer_authority():
		print("[MULTIPLAYER] Host authority detected. Swapping to gameplay scene...")
		get_tree().change_scene_to_file("res://scenes/multiplayertest.tscn")

func _player_left(id: int) -> void:
	print("[MULTIPLAYER] Peer left. Peer ID: ", id)
