extends Node2D
@onready var text_edit: TextEdit = $TextEdit
var can_connect = true
@onready var button_2: Button = $Button2
@onready var button_3: Button = $Button3
@onready var button: Button = $Button
@onready var label_2: Label = $Label2
@onready var label: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.full.connect(_room_full)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label_2.text = Network.error
	label.text = Network.msg

func _room_full () -> void: 
	can_connect = true
	button.disabled = false
	button_2.disabled = false
	button_3.disabled = false
	label.visible = false
func _on_button_pressed() -> void:
	button.disabled = true
	var text = text_edit.text.strip_edges()
	if text == "":
		can_connect = true
		button.disabled = false
		button_2.disabled = false
		button_3.disabled = false
		label.visible = false
		Network.error = "No code provided"
		return
	if can_connect:
		var possible = Network.join_room(text)
		
		if possible == false:
			can_connect = true
			button.disabled = false
			button_2.disabled = false
			button_3.disabled = false
			label.visible = false
			return
		else:
			label.visible = true
			button.disabled = true
			button_2.disabled = true
			button_3.disabled = true
			can_connect = false
	else:
		Network.error = "Error..."
		can_connect = true
		button.disabled = false
		button_2.disabled = false
		button_3.disabled = false
		label.visible = false


func _on_button_2_pressed() -> void:
	#menu
	get_tree().change_scene_to_file("res://scenes/multiplayer.tscn")
	
func _on_button_3_pressed() -> void:
	#connect
	get_tree().change_scene_to_file("res://scenes/invite.tscn")
