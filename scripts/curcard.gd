extends Node2D
@export var color:Color = Color("5f1e72ff")
@export var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
@export var texture: Texture2D = preload("res://icon.svg")


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var panel: Panel = $Panel
@onready var color_rect_2: Panel = $ColorRect2
@onready var color_rect: Panel = $ColorRect

var possible_colors = ["3840b9ff","07092fff","847025ff","5f1e72ff"]

#7 norms,  2 special!
var arraytocard = [["1","res://icon.svg"],["2","res://icon.svg"],["3","res://icon.svg"],["4","res://icon.svg"],["5","res://icon.svg"],["6","res://icon.svg"],["7","res://icon.svg"],["THEIF!","res://icon.svg"], ["STAR","res://icon.svg"]]
var cardType = ["1","res://icon.svg", "3840b9ff"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#give cur car
	get_new_card()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_new_card() -> void: 
	randomize()
	color = Color(possible_colors[randi_range(0,3)])
	var temp = arraytocard[randi_range(0,8)]
	cardType = [temp[0], temp[1], color]
	text = cardType[0]
	if text == "THEIF!":
		color ="56996eff"
	if text == "STAR":
		color = "e7beb8ff"
	if multiplayer.is_server():
		Manager.rpc("change_cur_card",cardType)
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
	
	
