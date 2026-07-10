extends Node2D
var done = false
var card = preload("res://scenes/card.tscn")
var first1 = true
var first2 = true
var first3 = true
var first4 = true
var first5 = true
############
var loaded_card0
var loaded_card_end0
var loaded_card_end1
var loaded_card_end2
var loaded_card_end3
var loaded_card_end4
var loaded_card_end5
var loaded_card1
var loaded_card2
var loaded_card3
var loaded_card4
var positions_array = [Vector2(120.0,774.0), Vector2(346.0,774.0),Vector2(571.0,774.0),Vector2(798.0,774.0),Vector2(1029.0,774.0)]
@onready var cards =[$Card, $Card2, $Card3, $Card4, $Card5]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0,5):
		var card_node = cards[i]
		if card_node == null:
			print(card_node)
			return
		var card_name ="loaded_card%d"%i
		var card_name_end ="loaded_card_end%d"%i
		set(card_name, card_node)
		set(card_name_end, (card_node.position.y -198))
		
	await get_tree().create_timer(0.8).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if first1 ||first2 ||first3 ||first4 ||first5:
		for i in range(0,5):
			var firstvariation = "first%d"%(i+1)
			if !get(firstvariation):
				continue
			var card_name1 ="loaded_card%d"%i
			var card_name_end1 ="loaded_card_end%d"%i
			var actual_card1  = get(card_name1)
			if actual_card1:
				var target_pos = lerp(actual_card1.position.y,get(card_name_end1), delta*13)
				#sets a certain property
				actual_card1.set_indexed("position:y",target_pos)
				if is_equal_approx(get(card_name_end1),target_pos):
					set(firstvariation, false)
				break
	else:
		done = true
				
