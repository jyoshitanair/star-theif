extends Node2D
@onready var panel_2: Panel = $Panel2
@onready var panel_3: Panel = $Panel3
@onready var button: Button = $Button
@onready var panel_4: Panel = $Panel4
var done = false
var card = preload("res://scenes/card.tscn")
var first1 = true
var first2 = true
var first3 = true
var first4 = true
var first5 = true
var switch_mode = false
var processing = false
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
var all_cards = []
var check_done = false
var good = false
var positions_array = [Vector2(120.0,774.0), Vector2(346.0,774.0),Vector2(571.0,774.0),Vector2(798.0,774.0),Vector2(1029.0,774.0)]
@onready var cards =[$Card, $Card2, $Card3, $Card4, $Card5]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0,5):
		var card_node = cards[i]
		card_node.index = i
		card_node.clicked.connect(_on_click.bind(i))
		card_node.position = positions_array[i]
		#set up array of what cars u have
		all_cards.append(card_node.cardType)
		if card_node == null:
			return
		var card_name ="loaded_card%d"%i
		var card_name_end ="loaded_card_end%d"%i
		set(card_name, card_node)
		set(card_name_end, (card_node.position.y -198))
	Manager.doneer.connect(_set_cards.bind(all_cards))	
	await get_tree().create_timer(0.8).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.changing_scenes:
		button.disabled = true
		return
	##wait for ready 
	
	if Manager.done && check_done == false:
		button.disabled = false
		check_done = true
		
	##good boy
	
	good = false
	if Manager.p1 != null && Manager.p2 != null:
		if multiplayer.get_unique_id() == Manager.p1:
			#am player one
			if Manager.p1turn:
				good = true
		else:
			#am p2
			if !Manager.p1turn:
				good = true
				
	if !good || switch_mode || Manager.local_click || !Manager.done || Manager.theif_mode: 
		button.disabled = true
	else: 
		button.disabled = false
		
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
		if not done: 
			Manager.fight_loaded = true
			Manager.test_ready(multiplayer.get_unique_id())
			done = true
func _on_click(index) -> void: 
	if Manager.changing_scenes:
		return
	Manager.handle_click.rpc(index)
	Manager.clicked_before = true	
func invalid_card() -> void: 
	if Manager.changing_scenes:
		return
	if !processing: 
		processing = true
		panel_2.show()
		await get_tree().create_timer(3.0).timeout
		panel_2.hide()
		processing = false
func _set_cards(card_node1) -> void:
	if Manager.changing_scenes:
		return 
	Manager.setcards.rpc.call_deferred(card_node1, multiplayer.get_unique_id())
		
func _on_button_pressed() -> void:
	if Manager.changing_scenes:
		return
	if Manager.done:
		panel_3.get_node("Label").text = "Choose your card to swap"
		switch_mode = true
		panel_3.visible = true
		button.disabled = true 
func show_theif_card() -> void: 
	if Manager.changing_scenes:
		return
	if Manager.done:
		panel_3.get_node("Label").text = "Choose your card to swap"
		panel_3.visible = true
		
func show_other_card() -> void: 
	if Manager.changing_scenes:
		return
	if Manager.done:
		panel_3.get_node("Label").text = "Choose their card to swap"
		panel_3.visible = true
func show_wait() -> void: 
	panel_4.visible = true
		
