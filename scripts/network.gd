extends Node
#p2p networking
var is_authenticated = false
var peer: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var client:WebSocketPeer = WebSocketPeer.new()
signal connection_established()
const SIGNAL_URL = "wss://relay.openrelayai.com/v1"
func _connect_to_signaler() -> int:
	var error = client.connect_to_url(SIGNAL_URL)
	return error
func host_room() -> void:
	var state = client.get_ready_state()
	if state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
		var error2 = _connect_to_signaler()
		if error2 != OK:
			print("fail")
			return
	peer.create_server()
	multiplayer.multiplayer_peer = peer
	set_process(true)
func _process(delta: float) -> void:
	client.poll() #new data?
	var state = client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not is_authenticated:
			var auth_packet = {
				"type":"auth",
				"apiKey": Secrets.API_KEY
			}
			client.send_text(JSON.stringify(auth_packet))
			is_authenticated = true
		
			####
		while client.get_available_packet_count() > 0:
			var packet_string = client.get_packet().get_string_from_utf8()
			_handle_mssg(packet_string)
	elif state == WebSocketPeer.STATE_CLOSED:
		print("uhhh connection closed")
		is_authenticated = false
		set_process(false)
func _ready() -> void:
	set_process(true)
	_connect_to_signaler()
func _handle_mssg(msg)-> void:
	var json = JSON.new()
	if json.parse(msg) != OK:
		print("failed to handle message")
		return
	var data = json.get_data()
	if data.has("type"):
		match data["type"]:
			"auth_success":
				print("Successfully authenticated! Device ID: ", data.get("deviceId"))
				connection_established.emit()
			"auth_error":
				print("Auth failed: ", data.get("message"))
			"response":
				print("Received response from backend: ", data.get("body"))
			"error":
				print("OpenRelay Error: ", data.get("message"))
