extends Node2D
@onready var label: Label = $Label
var connected = false
@onready var button: Button = $Button
var connected_once = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func on_recived() -> void: 
	pass

func _on_button_pressed() -> void:
	if connected:
		return
	var code = Network.create_room()
	label.text = code
	connected_once = true
	button.disabled = true
