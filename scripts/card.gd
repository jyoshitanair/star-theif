extends Node2D
@export var color:Color = Color("#95abdc")
@export var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
@export var texture: Texture2D = preload("res://icon.svg")
@onready var color_rect: ColorRect = $ColorRect
@onready var color_rect_2: ColorRect = $ColorRect2
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.color = color
	color_rect_2.color = color.lightened(0.4)
	sprite_2d.texture = texture
	label.text = text
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
