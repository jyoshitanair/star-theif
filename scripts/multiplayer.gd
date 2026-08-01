extends Node2D
@onready var target = [$Sprite2D2, $Sprite2D3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var target_size = [0.07,0.06]
	for i in range(target.size()):
		var element = target[i]
		var tween = create_tween().set_loops()
		tween.tween_property(element, "scale", Vector2(target_size[0],target_size[0]), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(element, "scale", Vector2(target_size[1], target_size[1]), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_3_pressed() -> void:
	##invite
	get_tree().change_scene_to_file("res://scenes/invite.tscn")


func _on_button_pressed() -> void:
	##join
	get_tree().change_scene_to_file("res://scenes/join.tscn")


func _on_button_2_pressed() -> void:
	##RULES
	get_tree().change_scene_to_file("res://scenes/rules.tscn")
	
