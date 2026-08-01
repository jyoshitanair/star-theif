extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var color_rect_2: Panel = $ColorRect2
@onready var panel: Panel = $Panel
@onready var color_rect: Panel = $ColorRect
@onready var label: Label = $Label
@onready var panel_2: Panel = $Panel2

@export var color = Color("ff0000ff")
@export var texture = "res://assets/images/Illustration 20260731 3_1.PNG"
@export var text = "LOADING..."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui([text, texture, color])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func update_ui(card) -> void:
	sprite_2d.texture = load(card[1])
	label.text = card[0]
	color = Color(card[2])
	_apply_panel_color(color_rect, color.darkened(0.4))
	_apply_panel_color(panel, color.lightened(0.4))
	_apply_panel_color(color_rect_2, color)
func _apply_panel_color(targetNode, color) -> void: 
		##
		var style = targetNode.get_theme_stylebox("panel").duplicate()
		style.bg_color = color
		targetNode.add_theme_stylebox_override("panel", style)
		##
