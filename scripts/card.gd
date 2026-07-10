extends Node2D
@export var color:Color = Color("#95abdc")
@export var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
@export var texture: Texture2D = preload("res://icon.svg")
@onready var color_rect: Panel = $ColorRect
@onready var color_rect_2: Panel = $ColorRect2
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var panel: Panel = $Panel
@onready var panel_2: Panel = $Panel2
var current = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	if current:
		panel.show()
		panel_2.hide()
	else:
		panel_2.show()
		panel.hide()
	print(current)

func _on_area_2d_mouse_entered() -> void:
	current = true
func _on_area_2d_mouse_exited() -> void:
	current = false
