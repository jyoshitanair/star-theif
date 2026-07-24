extends Node2D
@onready var label: Label = $Label
var player = preload("res://scenes/fight.tscn")
var player2 = preload("res://scenes/otherfight.tscn")
var connected_players = []
@onready var player_spawn: Node2D = $"player spawn"
@onready var label_2: Label = $Label2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn)
	multiplayer.peer_disconnected.connect(remove)
	label.text = Network.current_room_id
	label_2.text = str(multiplayer.get_unique_id())
	
	#meow
	for late in multiplayer.get_peers():
		spawn(late)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func spawn(id:int):
	if player_spawn.has_node(str(id)):
		return
	if id == multiplayer.get_unique_id():
		var player_instance = player.instantiate()
		player_instance.name = str(id)
		player_spawn.add_child(player_instance)
		player_instance.position = Vector2(0,0)
		#its me
	else:
		#not me
		var player2_instance = player2.instantiate()
		player2_instance.name = str(id)
		player_spawn.add_child(player2_instance)
		player2_instance.position = Vector2(0,-500)
	#p1 or p2?
	if not connected_players.has(id):
		connected_players.append(id)
	if connected_players.find(id) == 0:
		Manager.set_player(1)
	else:
		Manager.set_player(2)
func remove(id:int): 
	var player = player_spawn.get_node_or_null(str(id))
	if player:
		player.queue_free()
