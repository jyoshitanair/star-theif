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
	for card in their_cards.get_children():
		##get other_player
		for manager_element in other_player_set:
		#for i in range(len(other_player_set)):
			card.update_ui(manager_element)
	for card in their_cards.get_children():
		##get player_set
		for manager_element in player_set:
		#for i in range(len(player_set)):
			card.update_ui(manager_element)
		pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
