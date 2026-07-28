extends Node2D
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
signal clicked 
#7 norms,  2 special!
var arraytocard = [["1","res://icon.svg"],["2","res://icon.svg"],["3","res://icon.svg"],["4","res://icon.svg"],["5","res://icon.svg"],["6","res://icon.svg"],["7","res://icon.svg"],["THEIF!","res://icon.svg"], ["STAR","res://icon.svg"]]
var current = false
var old_current = false
var up
var down
var bar
var cardType = ["1","res://icon.svg"]
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
	if lerper: 
		position.y = lerp(position.y,lerpTarg, delta*13)
		if is_equal_approx(position.y, lerpTarg):
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
			Manager.change_cur_card.rpc(cardType)
	if lerper2:
		position.y = lerp(position.y,lerp2Targ, delta*13)
		if is_equal_approx(position.y, lerp2Targ):
			new_randi_card()
			lerper2 = false
			Manager.rpc("card_sender", multiplayer.get_unique_id(),cardType[0])
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
	if good && Manager.done && bar.done && ! Manager.clicked_before:
		if current:
			panel.show()
			panel_2.hide()
			if Input.is_action_just_pressed("clicked"):
				if Manager.is_possible(cardType) == false:
					bar.invalid_card()
					return
				Manager.card_clicked = cardType
				emit_signal("clicked")
				lerper = true
				lerpTarg = position.y - 200
				current = false
				old_current = false
				visual.position = down
				Manager.clicked_before = true
				print("me0w")
				#
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
func _on_area_2d_mouse_exited() -> void:
	if ! Manager.clicked_before:
		current = false
func change_text(new_txt) -> void: 
	text = new_txt
	label.text = text
func handle_showy()-> void: 	
	position.y += 200
	await get_tree().create_timer(0.5)
	randomize()
	cardType = arraytocard[randi_range(0,8)]
	text = cardType[0]
	texture = load(cardType[1])
func check_if_compatible () -> void: 
	pass
func new_randi_card()-> void :
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
