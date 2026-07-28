extends Node
signal pass_index(index)
signal doneer
var p1turn = true
var player = 1
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
var possible_colors = ["b657d3ff","9a8550ff","6587c6ff","d94d84ff"]
var arraytocard = [["1","res://icon.svg"],["2","res://icon.svg"],["3","res://icon.svg"],["4","res://icon.svg"],["5","res://icon.svg"],["6","res://icon.svg"],["7","res://icon.svg"],["THEIF!","res://icon.svg"], ["STAR","res://icon.svg"]]
var card_clicked
var color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(give)
func give(id) -> void: 
	if Network.is_host and random_card != null:
		change_cur_card.rpc_id(id, random_card)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 
@rpc("any_peer", "call_local")
func setcards(pe, sender)->void: 
	print("p1 = ",p1)
	print("p2 = ",p2)
	print("sender = ",sender)
	if p1 == sender:
		player1cards = pe
	if p2 == sender:
		player2cards = pe
func set_player(ini)->void:
	player = ini
@rpc("any_peer", "call_local")
func add_person(id, is_host) -> void:
	if is_host:
		#i am the host
		p1 = id
	else:
		p2 = id
	if p1 != null && p2 != null: 
		emit_signal("doneer")
func test_ready(it) -> void:
	if fight_loaded && otherfight_loaded:
		rpc("check_ready",it)
#sending data over the internet cause yeah :/
@rpc("any_peer", "call_remote")
func handle_click(index) -> void: 
	pass_index.emit(index)
@rpc("any_peer", "call_local")
func card_sender(id, card) -> void: 
	#get other guys clicks
	var other_guy = get_tree().get_first_node_in_group("p2")
	if other_guy:
		if other_guy.has_method("otherplayerwantin"):
			other_guy.otherplayerwantin(card)
@rpc("any_peer", "call_local")
func check_ready(id_test) -> void: 
	if !ready_players.has(id_test):
		ready_players.append(id_test)
	if ready_players.size()>=2:
		done = true
func newrandomcard() -> void: 
	#set up random card in the middle at the start
	#only host
	if p1 == multiplayer.get_unique_id():
		print("MANAGER")
		randomize()
		color = Color(possible_colors[randi_range(0,3)])
		var temp = arraytocard[randi_range(0,8)]
		if temp[0] == "THEIF!":
			color = Color("56996eff")
		if temp[0] == "STAR":
			color = Color("e7beb8ff")
		random_card = [temp[0], temp[1], color.to_html()]
		print("random:, ", random_card)
		change_cur_card.rpc(random_card)
@rpc("any_peer", "call_local")
func change_cur_card(random_card2) -> void: 
	random_card = random_card2
	print("anything?? ", random_card)
	for curcard in get_tree().get_nodes_in_group("main_card"):
		curcard.update_ui()
##updating local var 

#reseting a round

func reset() -> void: 
	ready_players.clear()
	done = false
	clicked_before = false
func is_possible(card) -> bool: 
	var my_term = card[0]
	var my_color = card[2]
	var needed_term = random_card[0]
	var needed_color = random_card[2]
	if my_color == needed_color:
		return true
	elif my_term == needed_term:
		return true
	elif my_term == "THEIF!":
		return true
	elif my_term == "STAR":
		return true
	else:
		print("my color ",my_color)
		print("my term ",my_term)
		print("the color ",needed_color)
		print("the term ",needed_term)
		return false
@rpc("any_peer", "call_local")
func update_set(p1orp2, cardType,index) -> void:
	var full 
	if p1orp2 == 1:
		full = Manager.player1cards
	if p1orp2 == 2:
		full = Manager.player2cards
	full[index] = cardType
	
	
