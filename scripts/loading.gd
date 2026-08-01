extends Node2D
@onready var button: Button = $Button
@onready var label: Label = $Label2
@onready var target = [$Label2, $Sprite2D2, $Sprite2D3]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##LABEL
	var length = [1.0,0.8,1.2]
	var target_size
	for i in range(target.size()):
		var element = target[i]
		var duration = length[i]
		if element is Label:
			element.pivot_offset = element.size/2
			target_size = [0.9,1.0]
		else:
			target_size = [0.08,0.1]
			
		var tween = create_tween().set_loops()
		tween.tween_property(element, "scale", Vector2(target_size[0],target_size[0]), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(element, "scale", Vector2(target_size[1], target_size[1]), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/multiplayer.tscn")
