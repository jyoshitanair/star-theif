extends Node2D
@onready var label: Label = $Label
@onready var button: Button = $Button
@onready var rules: Node2D = $"page 5"
var player = preload("res://scenes/fight.tscn")
var player2 = preload("res://scenes/otherfight.tscn")
var connected_players = []
@onready var start_but: Button = $Button2
@onready var fatty_but: Button = $"page 5/Button"
@onready var player_spawn: Node2D = $"player spawn"
@onready var label_2: Label = $Label2
@onready var label_3: Label = $Label3
@onready var checkmark: Sprite2D = $checkmark
@onready var panel: Panel = $Panel
@onready var label_4: Label = $Label4
@onready var spriteblue: Sprite2D = $Sprite2D2
@onready var spriteyellow: Sprite2D = $Sprite2D
var canclick = true
var maincard_loaded = false
var maincard = preload("res://scenes/curcard.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rules.z_index = 100
	checkmark.modulate.a = 0.0
	spawn.call_deferred(multiplayer.get_unique_id())
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
	label_4.text = "Total Turns: %d/10"%[floori(Manager.total_turns/2)]
	label_3.text = "Current Player Turn:  Player 1" if Manager.p1turn else "Current Player Turn:  Player 2"
func spawn(id:int):
	print("adding")
	print(Network.is_host)
	var player_is_host = false
	if id == multiplayer.get_unique_id():
		player_is_host = Network.is_host
	else:
		player_is_host = not Network.is_host
	Manager.add_person.rpc(id, player_is_host)
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
	if maincard_loaded == false:
		maincard = maincard.instantiate()
		add_child(maincard)
		maincard.z_index = 1
		maincard_loaded = true
	if Network.is_host: 
		spriteblue.visible = true
		spriteyellow.visible = false
	else:
		spriteyellow.visible = true
		spriteblue.visible = false
		
func remove(id:int): 
	var player = player_spawn.get_node_or_null(str(id))
	if player:
		player.queue_free()
	if connected_players.has(id):
		connected_players.erase(id)
	Manager.clean_up.rpc(id)

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
	
func _on_button_2_pressed() -> void:
	if rules.visible == true:
		rules.visible = false
		fatty_but.disabled = true
		start_but.disabled = false
		button.disabled = false
	else:
		rules.visible = true
		start_but.disabled = true
		fatty_but.disabled = false
		button.disabled = true
