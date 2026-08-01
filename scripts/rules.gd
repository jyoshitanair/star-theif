extends Node2D
@onready var page_array = [
[$"page 1","yes"], [$"page 1/SHOW_1","no"], [$"page 1/SHOW_2","no"], 
[$"page 1/SHOW_3","no"], [$"page 2","yes"], [$"page 2/SHOW_2","no"], 
[$"page 2/SHOW_3","no"], [$"page 3","yes"], [$"page 3/SHOW_2","no"], 
[$"page 3/SHOW_3","no"], [$"page 4","yes"], [$"page 4/SHOW_1","no"], 
[$"page 4/SHOW_2","no"], [$"page 4/SHOW_3","no"],[$"page 5","yes"], 
[$"page 6","yes"], [$"page 7","yes"]
]
@onready var current_page = $"page 1"
var index = 0 
func _on_button_pressed() -> void:
	print("CLICKED")
	index += 1
	if index >= page_array.size():
		call_deferred("_change")
		return
	var node = page_array[index][0]
	if page_array[index][1] == "yes":
		if current_page != null:
			current_page.visible = false
		current_page = node
	if node != null:
		_fade(node)
func _change() -> void: 
	get_tree().change_scene_to_file("res://scenes/multiplayer.tscn")
func _fade(node) -> void: 
	node.visible = true
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)
	await tween.finished
	tween.kill()
