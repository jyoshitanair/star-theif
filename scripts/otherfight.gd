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
var card_clicked
var positions_array = [Vector2(120.0,265.0), Vector2(346.0,265.0),Vector2(571.0,265.0),Vector2(798.0,265.0),Vector2(1029.0,265.0)]
@onready var cards =[$Card, $Card2, $Card3, $Card4, $Card5]
var lerper = false
var lerpTarg = false
var lerp2Targ = false
var lerper2 = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.pass_index.connect(_show_moving)
	for i in range(0,5):
		var card_node = cards[i]
		card_node.index = i
		card_node.texture = preload("res://icon.svg")
		if card_node == null:
			print(card_node)
			return
		var card_name ="loaded_card%d"%i
		var card_name_end ="loaded_card_end%d"%i
		card_node.position = positions_array[i]
		set(card_name, card_node)
		set(card_name_end, (card_node.position.y + 270))
		
	await get_tree().create_timer(0.8).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lerper: 
		card_clicked.position.y = lerp(card_clicked.position.y,lerpTarg, delta*13)
		if is_equal_approx(card_clicked.position.y, lerpTarg):
			print("DONNEEEEEEEEE")
			lerper = false
			await get_tree().create_timer(0.8).timeout
			lerp2Targ = card_clicked.position.y - 200
			#fade out
			var tween = create_tween()
			tween.tween_property(card_clicked, "modulate:a", 0.0, 1.0)
			await tween.finished
			card_clicked.modulate.a = 1.0
			#continue bleh belh
			card_clicked.position.y = card_clicked.position.y - 500
			await get_tree().create_timer(1.3).timeout
			lerper2 = true
	if lerper2:
		card_clicked.position.y = lerp(card_clicked.position.y,lerp2Targ, delta*13)
		if is_equal_approx(card_clicked.position.y, lerp2Targ):
			lerper2 = false
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
		if !done: 
			Manager.otherfight_loaded = true
			Manager.test_ready(multiplayer.get_unique_id())
		done = true
	
func otherplayerwantin(card_value) -> void: 
	#Manager.p1turn = !Manager.p1turn	
	#Manager.clicked_before = false
	pass
func _show_moving(index) -> void: 
	card_clicked = cards[index]
	lerper = true 
	lerpTarg = card_clicked.position.y +200
func show_card() -> void:
	print("HELLOOO????") 
	var showncard
	if Network.is_host: 
		showncard = Manager.player2cards
	else:
		showncard = Manager.player1cards
	for i in range(0,5):
		var card_node = cards[i]
		var cur_needed_card = showncard[ 4- i]
		card_node.update(cur_needed_card[0],Color(cur_needed_card[2]),cur_needed_card[1])
	var amount = randf_range(0.8,2.0)
	await get_tree().create_timer(amount).timeout
	for i in range(0,5):
		var card_node = cards[i]
		card_node.update("star theif!",Color("5b76b4ff"),"res://icon.svg")
