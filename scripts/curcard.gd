extends Node2D
var color:Color = Color("5f1e72ff")
var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
var texture: Texture2D = preload("res://icon.svg")


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var color_rect_2: Panel = $ColorRect2
@onready var color_rect: Panel = $ColorRect

var possible_colors = ["b657d3ff","9a8550ff","6587c6ff","d94d84ff"]

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
var cardType = ["1","res://assets/images/Illustration 20260731 3_8.PNG", "3840b9ff"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("main_card")
	get_new_card.call_deferred()

func update_card(newcard) -> void:
	if Manager.changing_scenes:
		return
	Manager.change_cur_card.rpc(newcard)
func get_new_card() -> void: 
	if Manager.changing_scenes:
		return
	if Manager.p1 == multiplayer.get_unique_id():
		Manager.newrandomcard()
func update_ui() -> void:
	if Manager.changing_scenes:
		return
	if Manager.random_card:
		sprite_2d.texture = load(Manager.random_card[1])
		label.text = Manager.random_card[0]
		color = Color(Manager.random_card[2])
		_apply_panel_color(color_rect, color.darkened(0.4))
		_apply_panel_color(color_rect_2, color)
func _apply_panel_color(targetNode, color) -> void:
	if Manager.changing_scenes:
		return 
	var style = targetNode.get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	targetNode.add_theme_stylebox_override("panel", style)
