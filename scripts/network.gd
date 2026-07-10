extends Node

var peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var client: WebSocketPeer = WebSocketPeer.new()

# Paste your actual Render WSS URL here!
const SIGNAL_URL = "wss://star-theif.onrender.com:443" 

var current_room_id: String = ""

func _ready() -> void:
	# Keep the process loop running so it can poll for network updates
	set_process(true)

func connect_to_match(room_name: String) -> void:
	current_room_id = room_name
	print("Connecting to room: ", current_room_id)
	
	var tls = TLSOptions.client_unsafe() # Forces Godot to skip strict verification
	var err = client.connect_to_url(SIGNAL_URL, tls)
	if err != OK:
		print("Failed to start connecting: ", err)

func _process(_delta: float) -> void:
	client.poll()
	peer.poll()
	
	if client.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while client.get_available_packet_count() > 0:
			var msg = client.get_packet().get_string_from_utf8()
			_handle_signaling(msg)

func _handle_signaling(msg: String) -> void:
	if msg.begins_with("I:"): 
		var my_id = msg.get_slice(":", 1).to_int()
		print("Connected to Signaler! Your ID: ", my_id)
		
		# Join the specific room the player typed in
		client.send_text("J:" + current_room_id)
		
		# Initialize the multiplayer mesh layer
		peer.create_mesh(my_id)
		multiplayer.multiplayer_peer = peer
		
		multiplayer.peer_connected.connect(_player_joined)
		multiplayer.peer_disconnected.connect(_player_left)

func _player_joined(id: int) -> void:
	print("Player connected! ID: ", id)
	
	# Only the host/authority should manage scene changing and spawning
	if multiplayer.is_multiplayer_authority():
		# If this is the very first player joining, load the world map
		get_tree().change_scene_to_file("res://scenes/multiplayertest.tscn")

func _player_left(id: int) -> void:
	print("Player left the room. ID: ", id)
