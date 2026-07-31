extends Node2D
@onready var page_array = [$"page 1", $"page 2", $"page 3", $"page 4", $"page 5", $"page 6"]
var index = 0 

func _on_button_pressed() -> void:
	print("CLICKED")
	##change the cur node
	page_array[index].visible = false
	index += 1
	if index >= 6:
		call_deferred("_change")
		return
	page_array[index].visible = true
func _change() -> void: 
	get_tree().change_scene_to_file("res://scenes/multiplayer.tscn")
