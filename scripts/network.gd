extends Node
const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"
func become_host():
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT, 2)
	multiplayer.multiplayer_peer = server_peer
	
	#what to run when someone connects
	multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(remove_player_from_game)
func join_as_p2():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP,SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
func add_player_to_game(id:int): #autopasses the id
	print(id, "join")
func remove_player_from_game(id:int):
	print(id, "removed")
