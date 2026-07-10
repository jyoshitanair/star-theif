extends Node2D
@onready var text_edit: TextEdit = $TextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var text = text_edit.text.strip_edges()
	if text == "":
		return
	Network.connect_to_match(text)
