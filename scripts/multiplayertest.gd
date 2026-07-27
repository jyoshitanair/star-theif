extends Node2D
@onready var label: Label = $Label
var player = preload("res://scenes/fight.tscn")
var player2 = preload("res://scenes/otherfight.tscn")
var connected_players = []
@onready var player_spawn: Node2D = $"player spawn"
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var curcard: Node2D = $curcard
@onready var checkmark: Sprite2D = $checkmark
@onready var panel: Panel = $Panel
var canclick = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkmark.modulate.a = 0.0
	spawn(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn)
	multiplayer.peer_disconnected.connect(remove)
	label.text = "Room Code: " + Network.current_room_id
	#meow
	for late in multiplayer.get_peers():
		spawn(late)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.p2 != null:
		panel.visible = false
	else:
		panel.visible = true
	if multiplayer.get_unique_id() == Manager.p1:
		label_2.text = "Player 1" 
	else:
		label_2.text = "Player 2"
	label_3.text = "Current Player Turn:  Player 1" if Manager.p1turn else "Current Player Turn:  Player 2"
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
	Manager.add_person.rpc(multiplayer.get_unique_id(), Network.is_host)
func remove(id:int): 
	var player = player_spawn.get_node_or_null(str(id))
	if player:
		player.queue_free()

func _on_button_pressed() -> void:
	if canclick:
		canclick = false
		DisplayServer.clipboard_set(Network.current_room_id)
		tweener(1.0)
		await get_tree().create_timer(2.0).timeout
		tweener(0.0)
		canclick = true
func tweener(end) -> void: 
	var tween = create_tween()
	tween.tween_property(checkmark, "modulate:a",end,0.8)
	await tween.finished
	tween.kill()
	
