extends Node
var player = 1
var move_clicked
var clicked_before= false
var player1cards = []
var player2cards = []
var otherfight_loaded = false
var fight_loaded = false
var ready_players = []
var done = false
var p1 
var p2
var p1_card_clicked
var p2_card_clicked
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 
func setcards(pe)->void: 
	if player == 1:
		player1cards.append(pe)
	if player == 2:
		player2cards.append(pe)
func set_player(ini)->void:
	player = ini
func test_ready(it) -> void:
	if fight_loaded && otherfight_loaded: 
		rpc("check_ready",it)
#sending data over the internet cause yeah :/
@rpc("any_peer", "call_local")
func card_sender(id, card) -> void: 
	#get other guys clicks
	var other_guy = get_tree().get_first_node_in_group("p2")
	if other_guy:
		print("pessi")
		if other_guy.has_method("otherplayerwantin"):
			other_guy.otherplayerwantin(id,card)
@rpc("any_peer", "call_local")
func check_ready(id_test) -> void: 
	if !ready_players.has(id_test):
		ready_players.append(id_test)
	if ready_players.size()>=2:
		print(ready_players)
		print("done")
		ready_players.sort()
		p1 = ready_players[0]
		p2 = ready_players[1]
		done = true
	print(ready_players)
	print("one pass")
	
	
