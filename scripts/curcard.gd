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
	add_to_group("main_card")
	get_new_card.call_deferred()
	print("jhellooo")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func update_card(newcard) -> void:
	Manager.change_cur_card.rpc(newcard)
func get_new_card() -> void: 
	print("Manager p1 ", Manager.p1)
	if Manager.p1 == multiplayer.get_unique_id():
		print("HELLOOOO??")
		Manager.newrandomcard()
func update_ui() -> void:
	if Manager.random_card:
		sprite_2d.texture = load(Manager.random_card[1])
		label.text = Manager.random_card[0]
		color = Color(Manager.random_card[2])
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
		
		
