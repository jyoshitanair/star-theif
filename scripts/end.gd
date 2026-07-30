extends Node2D
@onready var their_cards: Node2D = $"their cards"
@onready var your_cards: Node2D = $"your cards"
@onready var play_yours: Panel = $play_yours
@onready var play_theirs: Panel = $play_theirs
var player = 1
var player_set
var other_player_set = 2
var done = 0  
@onready var yourpoints: Panel = $yourpoints
@onready var theirpoints: Panel = $theirpoints
var text = "???"
var othertext = "???"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = 1 if Network.is_host else 2
	text = str(Manager.player1points)  if player == 1 else str(Manager.player2points)
	othertext = str(Manager.player2points)  if player == 1 else str(Manager.player1points)
	player_set = Manager.get("player%dcards"%[player])
	other_player_set = Manager.get("player%dcards"%[3-player])
	#end = 3- start   (3-1 = 2) or (3-2 = 1)
	var theirSet =  their_cards.get_children()
	var yourSet =  your_cards.get_children()
	for i in range(min(theirSet.size(),other_player_set.size())):
		theirSet[i].update_ui(other_player_set[i])
	for i in range(min(yourSet.size(),player_set.size())):
		yourSet[i].update_ui(player_set[i])
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if done < 2:
		if your_cards.done: 
			yourpoints.get_node("Label").text = str(text)
			done += 1 	
		if their_cards.done: 
			theirpoints.get_node("Label").text = str(othertext)
			done += 1 	
	if done == 2:
		play_yours.visible = true
		play_theirs.visible = true
		var yours = your_cards.poker_points_names
		var theirs = their_cards.poker_points_names
		play_yours.get_node("Label").text = "+%d Points, played: %s "%yours
		play_theirs.get_node("Label").text = "+%d Points, played: %s "%theirs
		done += 1
