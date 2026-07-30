extends Node2D
var is_theirs = false
var backup_needed = null
var cards
var total_time = 0 

var first1 = true
var first2 = true
var first3 = true
var first4 = true
var first5 = true
var done = false

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().get_first_node_in_group("their_slide") == self:
		is_theirs = true
		backup_needed = get_tree().get_first_node_in_group("your_slide")
	cards = get_children()
	for i in range(0,5):
		var card_node = cards[i]
		var card_name ="loaded_card%d"%i
		var card_name_end ="loaded_card_end%d"%i
		set(card_name, card_node)
		if is_theirs:
			set(card_name_end, (card_node.position.x + 830))
		else:
			set(card_name_end, (card_node.position.x - 830))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	##ANIMATION!!
	if check_valid(delta):
		if first1 ||first2 ||first3 ||first4 ||first5:
			for i in range(4,-1,-1):
				var firstvariation = "first%d"%(i+1)
				if !get(firstvariation):
					continue
				var card_name1 ="loaded_card%d"%i
				var card_name_end1 ="loaded_card_end%d"%i
				var actual_card1  = get(card_name1)
				if actual_card1:
					var target_pos = lerp(actual_card1.position.x,get(card_name_end1), delta*13)
					#sets a certain property
					actual_card1.set_indexed("position:x",target_pos)
					if is_equal_approx(get(card_name_end1),target_pos):
						set(firstvariation, false)
					break
	else:
		if not done: 
			done = true
func check_valid(delta) -> bool: 
	if backup_needed != null:
		return true
	else:
		total_time += delta
		if total_time >= 4:
			return true
		else:
			return false
		##THIS HAS TO WAIT
		
