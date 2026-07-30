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

var poker_points_names
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	####
	var local_player = 1 if Network.is_host else 2
	if get_tree().get_first_node_in_group("their_slide") == self:
		is_theirs = true
		var target_player = 3 - local_player #reciprocal
		poker_points_names = check_combos(target_player)
		backup_needed = get_tree().get_first_node_in_group("your_slide")
	else:
		poker_points_names = check_combos(local_player)
	cards = get_children()
	for i in range(0,5):
		var card_node = cards[i]
		var card_name ="loaded_card%d"%i
		var card_name_end ="loaded_card_end%d"%i
		set(card_name, card_node)
		if is_theirs:
			set(card_name_end, (card_node.position.x + 950))
		else:
			set(card_name_end, (card_node.position.x - 950))
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
func check_combos(noot) -> Array: 
	var deck = Manager.player1cards if noot == 1 else Manager.player2cards
	var total_stars = 0 
	var total_theived = 0 
	var numbers = {}
	var colors = {}
	for cardType in deck:
		var term = cardType[0]
		if numbers.has(term):
			numbers[term] += 1
		else:
			numbers[term] = 1
		var color = cardType[2]
		if colors.has(color):
			colors[color] += 1
		else:
			colors[color] = 1
		if term == "STAR":
			total_stars += 1
		if term == "THEIF!":
			total_theived += 1
	### 
	var max_num = 0 
	for element in numbers.values():
		if element > max_num:
			max_num = element
	var max_colors = 0 
	for element in colors.values():
		if element > max_colors:
			max_colors = element
	###	
	
	if total_stars == 5:
		return [14, "Supernova!"]
	if total_theived == 5:
		return [12, "Master Theif!"]
	if numbers.get("7", 0) == 5 && max_colors >= 5:
		return [10, "Crazy Sevens"]
	if deck[1][0] == "7" and deck[2][0] == "STAR" and deck[3][0] == "7":
		return [9, "Star Sandwich"]
	if numbers.get("7", 0) == 5:
		return [7, "Lucky Sevens"]
	if max_colors >= 4:
		return [5, "Flush"]	
	if max_num >= 4:
		return [5, "4 of a kind"]	
	if max_num >= 3:
		return [3, "3 of a kind"]	
	if max_num >= 2:
		return [3, "Pair"]	
	if total_stars >= 1 or total_theived >= 1:
		return [1, "High Card"]
	return [0, "Nothing :/"]
	##poker combinations: 
	##all stars[14], all theifs[12],
	##all sevens and same color[9], (X,7,star,7,X)[7],
	##all sevens[5], 4 of the same color[3],
	##4 same number[3], 2 of the same number[2], a high card(STAR/THEIF)[1],		
