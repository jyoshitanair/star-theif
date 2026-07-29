extends Node2D
@onready var text_edit: TextEdit = $TextEdit
var connected_once= true
@onready var button: Button = $Button
@onready var label_2: Label = $Label2
@onready var label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label_2.text = Network.error
	label.text = Network.msg


func _on_button_pressed() -> void:
	print("clicked2")
	var text = text_edit.text.strip_edges()
	if text == "":
		return
	if connected_once:
		Network.join_room(text)
		connected_once = false
		button.disabled = true
	else:
		get_tree().change_scene_to_file("res://scenes/join.tscn")
