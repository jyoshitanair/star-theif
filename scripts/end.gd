extends Node2D
@onready var their_cards: Node2D = $"their cards"
@onready var your_cards: Node2D = $"your cards"
var player = 1
var player_set
var other_player_set = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = 1 if Network.is_host else 2
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
	pass
