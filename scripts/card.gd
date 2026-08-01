extends Node2D
var locked = false
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@export var color:Color = Color("e7beb8ff")
@export var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
@export var texture: Texture2D = preload("res://icon.svg")
#theif = steal an opponents card, star = see the oponents cards for 1 second.
@onready var panel: Panel = $visual/Panel
@onready var color_rect: Panel = $visual/ColorRect
@onready var color_rect_2: Panel = $visual/ColorRect2
@onready var sprite_2d: Sprite2D = $visual/Sprite2D
@onready var label: Label = $visual/Label
@onready var panel_2: Panel = $visual/Panel2
@onready var visual: Node2D = $visual
var possible_colors = ["b657d3ff","9a8550ff","6587c6ff","d94d84ff"]
var good = false
var busy = false
var index
signal theif_clicked
var old_card 
signal clicked 
#7 norms,  2 special!
var arraytocard = [
["1","res://assets/images/Illustration 20260731 3_8.PNG"],
["2","res://assets/images/Illustration 20260731 3_3.PNG"],
["3","res://assets/images/Illustration 20260731 3_9.PNG"],
["4","res://assets/images/Illustration 20260731 3_7.PNG"],
["5","res://assets/images/Illustration 20260731 3_5.PNG"],
["6","res://assets/images/Illustration 20260731 3_4.PNG"],
["7","res://assets/images/Illustration 20260731 3_10.PNG"],
["THEIF!","res://assets/images/Illustration 20260731 3_2.PNG"], 
["STAR","res://assets/images/Illustration 20260731 3_6.PNG"]]
var current = false
var old_current = false
var up
var down
var bar
var cardType = ["1","res://assets/images/Illustration 20260731 3_8.PNG"]
var lerper = false
var lerpTarg
var lerper2 = false
var lerp2Targ
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_randi_card()
	bar = get_parent()
	up = Vector2(0, - 50)
	down =Vector2.ZERO
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.changing_scenes:
		return
	if busy: 
		return 
	if lerper: 
		position.y = lerp(position.y,lerpTarg, delta*13)
		if is_equal_approx(position.y, lerpTarg):
			if cardType[0]== "STAR":
				#star stuff 
				var other = get_tree().get_first_node_in_group("p2")
				busy = true 
				await other.show_card()
				busy = false 
			print("DONNEEEEEEEEE")
			lerper = false
			await get_tree().create_timer(0.8).timeout
			lerp2Targ = position.y + 200
			#fade out
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 1.0)
			await tween.finished
			modulate.a = 1.0
			#continue bleh belh
			position.y = position.y + 500
			await get_tree().create_timer(1.3).timeout
			lerper2 = true
			panel_2.show()
			panel.hide()
			#if cardType[0] != "THEIF!":
			Manager.change_cur_card.rpc(cardType)
			if cardType[0] == "THEIF!": 
				#theif stuff
				var other = get_tree().get_first_node_in_group("fightbar")
				if other and "button" in other:
					other.button.disabled = true 
				bar.show_theif_card()
				Manager.clicked_before = false
	if lerper2:
		position.y = lerp(position.y,lerp2Targ, delta*13)
		if is_equal_approx(position.y, lerp2Targ):
			var old_card = cardType[0]
			var played_theif = (old_card == "THEIF!")
			new_randi_card()
			#if Network.is_host:
				#Manager.update_set.rpc(1,cardType, index)
			#else:
				#Manager.update_set.rpc(2,cardType, index)
			if not played_theif:
				print("GOING TO TOGGLEE")
				Manager.js_toggle_turn.rpc()
			lerper2 = false
			Manager.local_click = false
			locked = false
			var player = 1 if Network.is_host else 2
			Manager.updatepoints.rpc(player)
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
	if good && Manager.done && bar.done && ! Manager.clicked_before and !locked:
		if current:
			panel.show()
			panel_2.hide()
			if Input.is_action_just_pressed("clicked"):
				locked = true
				Manager.local_click = true
				bar.button.disabled = true
				if Manager.theif_mode:
					print("THEIF MODEE!!")
					#next card clicked is the thing to switch!
					emit_signal("theif_clicked",index) 
					Manager.clicked_before = true
					Manager.local_click = false
					Manager.theif_mode = false
					current = false
					old_current = false
					visual.position = down
					panel_2.show()
					panel.hide()
					return
					#old_card = cardType
				if bar.switch_mode == true and bar.done: 
					print("IM SWITCHING")
					var p1orp2 = 1 if Network.is_host else 2
					new_randi_card()
					#Manager.update_set.rpc(p1orp2, cardType,index)	
					Manager.js_toggle_turn.rpc()
					bar.switch_mode = false
					bar.panel_3.visible = false
					current = false
					old_current = false
					visual.position = down
					panel_2.show()
					panel.hide()
					Manager.local_click = false
					return
				####
				var p1orp2 = 1 if Network.is_host else 2
				if Manager.is_possible(index, p1orp2) == false:
					bar.invalid_card()
					Manager.local_click = false
					bar.button.disabled = false
					locked = false
					return	
				if cardType[0] == "THEIF!":
					Manager.theif_mode = true
					emit_signal("clicked")
					lerper = true
					lerpTarg = position.y - 200
					current = false
					old_current = false
					visual.position = down
					return
				else:
					Manager.clicked_before = true
					Manager.card_clicked = cardType
					emit_signal("clicked")
					lerper = true
					lerpTarg = position.y - 200
					current = false
					old_current = false
					visual.position = down
					return
		else:
			panel_2.show()
			panel.hide()
		if current != old_current:
			visual.position = down if !current else  up
			old_current = current  

func _on_area_2d_mouse_entered() -> void:
	if ! Manager.clicked_before:
		current = true
	if Manager.changing_scenes:
		current = false
func _on_area_2d_mouse_exited() -> void:
	if ! Manager.clicked_before:
		current = false
func change_text(new_txt) -> void: 
	if Manager.changing_scenes:
		return
	text = new_txt
	label.text = text
func handle_showy()-> void: 
	if Manager.changing_scenes:
		return	
	position.y += 200
	await get_tree().create_timer(0.5)
	randomize()
	cardType = arraytocard[randi_range(0,8)]
	text = cardType[0]
	texture = load(cardType[1])
#func check_if_compatible () -> void: 
	#pass
func new_randi_card()-> void :
	if Manager.changing_scenes:
		return
	randomize()
	color = Color(possible_colors[randi_range(0,3)])
	var temp = arraytocard[randi_range(0,8)]
	if temp[0] == "THEIF!":
		color = Color("56996eff")
	if temp[0] == "STAR":
		color = Color("e7beb8ff")
	cardType = [temp[0], temp[1], color.to_html()]
	text = cardType[0]
	texture = load(cardType[1])
	sprite_2d.texture = texture
	label.text = text
	
	##
	var style = panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = color.lightened(0.4)
	panel.add_theme_stylebox_override("panel", style)
	##
	var style2 = color_rect_2.get_theme_stylebox("panel").duplicate()
	style2.bg_color = color.darkened(0.4)
	color_rect.add_theme_stylebox_override("panel", style2)
	##
	var style3 = color_rect_2.get_theme_stylebox("panel").duplicate()
	style3.bg_color = color
	color_rect_2.add_theme_stylebox_override("panel", style3)
	
	##ALWAYS ALWAYS UPDATE!!
	if index != null:
		var p1orp2 = 1 if Network.is_host else 2
		Manager.update_set.rpc(p1orp2, cardType, index)
func update_ui(card) -> void:
	if Manager.changing_scenes:
		return
	print("CHANGING, ", self.name, "TO ", card)
	sprite_2d.texture = load(card[1])
	label.text = card[0]
	color = Color(card[2])
	_apply_panel_color(color_rect, color.darkened(0.4))
	_apply_panel_color(panel, color.lightened(0.4))
	_apply_panel_color(color_rect_2, color)
	locked = false
func _apply_panel_color(targetNode, color) -> void: 
		if Manager.changing_scenes:
			return
		##
		var style = targetNode.get_theme_stylebox("panel").duplicate()
		style.bg_color = color
		targetNode.add_theme_stylebox_override("panel", style)
		##
