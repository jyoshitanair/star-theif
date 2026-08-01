extends Node
## AUDIO 
var audio
var music_path = preload("res://assets/music/purrplecat-cat-nap-lofi-hiphop-beats-199252.mp3")
###
var mayclick = false
var finished_players = []
var changing_scenes = false
var total_turns = 0 
var synced_players = []
var theif_mode = false
signal pass_index(index)
signal doneer
var local_click = false
var player1points = 0 
var player2points = 0 
var first_time = false
var theifcard
var theif = false
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
var arraytocard = [
["1","res://assets/images/Illustration 20260731 3_8.PNG"],
["2","res://assets/images/Illustration 20260731 3_3.PNG"],
["3","res://assets/images/Illustration 20260731 3_9.PNG"],
["4","res://assets/images/Illustration 20260731 3_7.PNG"],
["5","res://assets/images/Illustration 20260731 3_5.PNG"],
["6","res://assets/images/Illustration 20260731 3_4.PNG"],
["7","res://assets/images/Illustration 20260731 3_10.PNG"],
["THEIF!","res://assets/images/Illustration 20260731 3_2.PNG"], 
["STAR","res://assets/images/Illustration 20260731 3_6.PNG"]]
var card_clicked
var color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = music_path
	audio.volume_db = -5
	play_song()
	multiplayer.peer_connected.connect(give)
func play_song() -> void: 
	if audio and not audio.playing:
		audio.play()
func _process(delta: float) -> void:
	play_song()
@rpc("any_peer", "call_local")
func js_toggle_turn() -> void: 
	if changing_scenes:
		return
	p1turn = !p1turn
	total_turns += 1
	clicked_before = false
	if total_turns == 20:
		#ITS BEEN TEN MOVES!
		changing_scenes = true
		var node_show = get_tree().get_first_node_in_group("fightbar")
		node_show.show_wait()
		await get_tree().create_timer(5.0).timeout
		scene_change.rpc()
@rpc("any_peer", "call_local")
func scene_change() -> void: 
	get_tree().change_scene_to_file("res://scenes/end.tscn")
@rpc("any_peer", "call_local")
func card_syncer(id) -> void: 
	if changing_scenes:
		return
	if not synced_players.has(id): 
		synced_players.append(id)
	if synced_players.size() >= 2: 
		synced_players.clear()
		rpc("js_toggle_turn")
@rpc("any_peer", "call_local")
func switcheroo(p1_index, p2_index) -> void:
	if changing_scenes:
		return
	if p1_index >= player1cards.size() or  p2_index >= player2cards.size():
		return
	var temp = player1cards[p1_index]
	var temp2 = player2cards[p2_index]
	player1cards[p1_index] = temp2
	player2cards[p2_index] = temp
	##SOMETHING TO UPDATE UII!!
	##the node
	var fightbar = get_tree().get_first_node_in_group("fightbar")
	if !fightbar: 
		return
	#UPDATE UI!!
	#updateable is me!
	var p1calling = (p1 == multiplayer.get_unique_id())
	for card in fightbar.cards:
		if card.index == p1_index && p1calling:
			##this is the node that started it!!
			card.update_ui(player1cards[p1_index])
		if card.index == p2_index && !p1calling:
			card.update_ui(player2cards[p2_index])
	##UPDATE OTHER PLAYER UI!!
	
func give(id) -> void: 
	if changing_scenes:
		return
	if Network.is_host and random_card != null:
		change_cur_card.rpc_id(id, random_card)
@rpc("any_peer", "call_local")
func updatepoints(p1o2p2)-> void:
	if changing_scenes:
		return 
	if p1o2p2 == 1: 
		player1points += 1
	if p1o2p2 == 2: 
		player2points += 1
@rpc("any_peer", "call_local")
func setcards(pe, sender)->void: 
	if changing_scenes:
		return
	if sender == p1:
		player1cards = pe.duplicate(true)
	if sender == p2:
		player2cards = pe.duplicate(true)
	
func set_player(ini)->void:
	if changing_scenes:
		return
	player = ini
@rpc("any_peer", "call_local")
func add_person(id, is_host) -> void:
	if changing_scenes:
		return
	if is_host:
		#i am the host
		p1 = id
	else:
		p2 = id
	if p1 != null && p2 != null: 
		emit_signal("doneer")
func test_ready(it) -> void:
	if changing_scenes:
		return
	if fight_loaded && otherfight_loaded:
		rpc("check_ready",it)
#sending data over the internet cause yeah :/
@rpc("any_peer", "call_remote")
func handle_click(index) -> void:
	if changing_scenes:
		return 
	pass_index.emit(index)
@rpc("any_peer", "call_local")
func check_ready(id_test) -> void: 
	if changing_scenes:
		return
	if !ready_players.has(id_test):
		ready_players.append(id_test)
	if ready_players.size()>=2:
		done = true
func newrandomcard() -> void: 
	if changing_scenes:
		return
	#set up random card in the middle at the start
	#only host
	if p1 == multiplayer.get_unique_id():
		randomize()
		color = Color(possible_colors[randi_range(0,3)])
		var temp = arraytocard[randi_range(0,8)]
		if temp[0] == "THEIF!":
			color = Color("56996eff")
		if temp[0] == "STAR":
			color = Color("e7beb8ff")
		random_card = [temp[0], temp[1], color.to_html()]
		change_cur_card.rpc(random_card)
@rpc("any_peer", "call_local")
func change_cur_card(random_card2) -> void: 
	if changing_scenes:
		return
	random_card = random_card2
	for curcard in get_tree().get_nodes_in_group("main_card"):
		curcard.update_ui()
##updating local var 

#reseting a round

func reset() -> void: 
	if changing_scenes:
		return
	ready_players.clear()
	done = false
	clicked_before = false
func is_possible(index, player) -> bool: 
	var card_set = Manager.player1cards if player == 1 else Manager.player2cards
	if index < 0 or index >= card_set.size():
		var fightbar = get_tree().get_first_node_in_group("fightbar")
		fightbar._set_cards(fightbar.all_cards)
		print(fightbar.all_cards)
		return false
	if random_card == null or random_card.size() < 3:
		return false
	var card = card_set[index]
	if changing_scenes:
		return false
	var my_term = card[0]
	var my_color = card[2]
	var needed_term = random_card[0]
	var needed_color = random_card[2]
	if my_color == needed_color:
		return true
	elif my_term == needed_term:
		return true
	elif my_term == "THEIF!" || needed_term == "THEIF!":
		#theif = true 
		return true
	elif my_term == "STAR" || needed_term == "STAR" :
		return true
	else:
		return false
@rpc("any_peer", "call_local")
func update_set(p1orp2, cardType,index) -> void:
	if changing_scenes:
		return
	var full 
	if p1orp2 == 1:
		full = Manager.player1cards
	if p1orp2 == 2:
		full = Manager.player2cards
	full[index] = cardType
@rpc("any_peer", "call_local")
func clean_up(id) -> void: 
	if changing_scenes:
		return
	# Unassign player slots
	if p1 == id:
		##IF PLAYER 1 LEAVES MAKE P2 THE NEW P1
		p1 = p2
		p2 = null
	elif p2 == id:
		p2 = null
	## REASSING HOST
	if multiplayer.get_unique_id() == p1:
		Network.is_host = true
	else:
		Network.is_host = false
		
	##VARS
	mayclick = false
	theif_mode = false
	local_click = false
	theif = false
	theifcard = null
	done = false
	p1turn = true
	clicked_before = false
	fight_loaded = false
	otherfight_loaded = false
	player1cards.clear()
	player2cards.clear()
	ready_players.clear()
	synced_players.clear()
	random_card = []
	player1points = 0
	player2points = 0
	if Network.is_host:
		newrandomcard()
@rpc("any_peer", "call_local")
func play_again(id) -> void: 
	if !finished_players.has(id):
		finished_players.append(id)
	if finished_players.size()>=2:
		reset_game()
		get_tree().change_scene_to_file("res://scenes/multiplayertest.tscn")
@rpc("any_peer", "call_local")
func reset_game() -> void: 
	changing_scenes = false
	total_turns = 0 
	finished_players.clear()
	done = false
	p1turn = true
	mayclick = false
	clicked_before = false
	fight_loaded = false
	otherfight_loaded = false
	player1cards.clear()
	player2cards.clear()
	ready_players.clear()
	synced_players.clear()
	random_card = []
	player1points = 0
	player2points = 0
	theif_mode = false
	local_click = false
	theif = false
	theifcard = null
	first_time = false
	
	
