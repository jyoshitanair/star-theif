extends Node
var p1turn = true
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
var random_card
var arraytocard = [["1","res://icon.svg"],["2","res://icon.svg"],["3","res://icon.svg"],["4","res://icon.svg"],["5","res://icon.svg"],["6","res://icon.svg"],["7","res://icon.svg"],["THEIF!","res://icon.svg"], ["STAR","res://icon.svg"]]
var card_clicked
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#give cur car
	random_card = "test"
	multiplayer.peer_connected.connect(give)
func give(id) -> void: 
	if multiplayer.is_server():
		if random_card == null:
			#if its not there at this point we hv issues
			randomize()
			random_card = arraytocard[randi_range(0,8)]
		rpc_id(id, "change_cur_card", random_card)
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
			other_guy.otherplayerwantin(card)
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
func newrandomcard() -> void: 
	#set up random card in the middle at the start
	#only host
	if multiplayer.is_server():
		randomize()
		random_card = arraytocard[randi_range(0,8)]
		rpc("change_cur_card",random_card)
@rpc("any_peer", "call_local")
func change_cur_card(random_card2) -> void: 
	random_card = random_card2
	print("anything?? ", random_card)
	for curcard in get_tree().get_nodes_in_group("main_card"):
		print("found one!")
		curcard.get_node_or_null("Label").text = random_card2[0]
		curcard.get_node_or_null("Sprite2D").texture = load(random_card2[1])	
##updating local var 
	
