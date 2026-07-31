extends Node2D
@onready var their_cards: Node2D = $"their cards"
@onready var your_cards: Node2D = $"your cards"
@onready var play_yours: Panel = $play_yours
@onready var play_theirs: Panel = $play_theirs
@onready var spriteblue: Sprite2D = $Sprite2D2
@onready var spriteyellow: Sprite2D = $Sprite2D
var player = 1
var player_set
var other_player_set = 2
var your_done = false  
var their_done = false 
@onready var button: Button = $winner/Button

var their_total_points = 0 
var your_total_points = 0 
var time = 0 

@onready var winnerp: Panel = $winner
@onready var yourpoints: Panel = $yourpoints
@onready var theirpoints: Panel = $theirpoints
var text = 0
var othertext = 0

var your_processed = false
var their_processed = false
var your_done_processing = false
var their_done_processing = false
var result_calced = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Network.is_host: 
		spriteblue.visible = true
		spriteyellow.visible = false
	else:
		spriteyellow.visible = true
		spriteblue.visible = false
	button.disabled = true
	player = 1 if Network.is_host else 2
	text = Manager.player1points  if player == 1 else Manager.player2points
	othertext = Manager.player2points  if player == 1 else Manager.player1points
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
	if your_cards.done and not your_processed: 
		yourpoints.get_node("Label").text = "Base: "+ str(text)
		your_total_points += text
		your_done = true
		your_processed = true
	if their_cards.done and not their_processed: 
		theirpoints.get_node("Label").text = "Base: " +str(othertext)
		their_total_points += othertext
		their_done = true	
		their_processed = true
	if your_done and not your_done_processing:
		play_yours.visible = true
		var yours = your_cards.poker_points_names
		play_yours.get_node("Label").text = "+%d Points, played: %s "%yours
		your_total_points += yours[0]
		your_done_processing = true 
	if their_done and not their_done_processing:
		play_theirs.visible = true
		var theirs = their_cards.poker_points_names
		play_theirs.get_node("Label").text = "+%d Points, played: %s "%theirs
		their_total_points += theirs[0]
		their_done_processing = true 
	if your_done and their_done and not result_calced:
		time += delta
		if time >= 2:
			var winner
			button.disabled = false
			if your_total_points > their_total_points:
				winner = " You win!"
			if your_total_points < their_total_points:
				winner = " You lost :("
			if your_total_points == their_total_points:
				winner = "Woah it's a tie!"
			winnerp.visible = true
			winnerp.get_node("Label").text = winner
			result_calced = true
func _on_button_pressed() -> void:
	print("ONE PLAYER CLICKED IT")
	button.disabled = true
	Manager.play_again.rpc(multiplayer.get_unique_id())
