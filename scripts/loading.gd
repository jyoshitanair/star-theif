extends Node2D
@onready var button: Button = $Button
@onready var label: Label = $Label2



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.pivot_offset = label.size/2
	var tween = create_tween().set_loops()
	tween.tween_property(label, "scale", Vector2(0.9,0.9), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(label, "scale", Vector2(1.0,1.0), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/multiplayer.tscn")
