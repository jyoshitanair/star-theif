extends Node2D
@export var color:Color = Color("#95abdc")
@export var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
@export var texture: Texture2D = preload("res://icon.svg")
@export var move_clicked:String = "speed"


@onready var panel: Panel = $visual/Panel
@onready var color_rect: Panel = $visual/ColorRect
@onready var color_rect_2: Panel = $visual/ColorRect2
@onready var sprite_2d: Sprite2D = $visual/Sprite2D
@onready var label: Label = $visual/Label
@onready var panel_2: Panel = $visual/Panel2
@onready var visual: Node2D = $visual
#7 norms,  2 special!
var arraytocard = [["1","res://icon.svg"],["2","res://icon.svg"],["3","res://icon.svg"],["4","res://icon.svg"],["5","res://icon.svg"],["6","res://icon.svg"],["7","res://icon.svg"],["THEIF!","res://icon.svg"], ["STAR","res://icon.svg"]]
var current = false
var old_current = false
var up
var down
var bar
var cardType = ["1","res://icon.svg"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	cardType = arraytocard[randi_range(0,8)]
	text = cardType[0]
	texture = load(cardType[1])
	bar = get_parent()
	up = Vector2(0, - 50)
	down =Vector2.ZERO
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.clicked_before:
		return
	if bar.done && ! Manager.clicked_before:
		if current:
			panel.show()
			panel_2.hide()
			if Input.is_action_just_pressed("clicked"):
				Manager.move_clicked = move_clicked
				current = false
				Manager.clicked_before = true
				print("me0w")
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
