extends Node
var player = 1
var move_clicked
var clicked_before= false
var player1cards = []
var player2cards = []
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
