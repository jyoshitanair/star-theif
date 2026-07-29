extends Node2D
@export var color:Color = Color("5b76b4ff")
@export var text:String = "googesjhljhkjlhjhjhjhljkhjhkjlhjhjkhlhjhlkhjhkjhlhjhl"
@export var texture = "res://icon.svg"
var index = 0 
@onready var panel: Panel = $visual/Panel
@onready var color_rect: Panel = $visual/ColorRect
@onready var color_rect_2: Panel = $visual/ColorRect2
@onready var sprite_2d: Sprite2D = $visual/Sprite2D
@onready var label: Label = $visual/Label
var mayclick = false
var current = false
var old_card
var bar
func update(text1, color1, texture1) -> void: 
	color = Color(color1)
	text = text1
	texture = load(texture1)
	sprite_2d.texture = texture
	label.text = text
	##
	var style = panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = color.lightened(0.4)
	panel.add_theme_stylebox_override("panel", style)
	##
	var style2 = color_rect_2.get_theme_stylebox("panel").duplicate()
	style2.bg_color = color.darkened(0.4)
	color_rect.add_theme_stylebox_override("panel", style2)
	##
	var style3 = color_rect_2.get_theme_stylebox("panel").duplicate()
	style3.bg_color = color
	color_rect_2.add_theme_stylebox_override("panel", style3)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cards = get_tree().get_nodes_in_group('card')
	for card in cards:
		card.theif_clicked.connect(_ask_to_switch)
	bar = get_parent()
	update("star theif!",color,texture)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("clicked"):
		if mayclick and current: 
			print("yes")
			mayclick = false
			print("IVE BEEN CLICKED ",old_card )
			var temp_index = 4 - index
				##cards are stored 0,1,2,3,4. displayed 4,3,2,1,0.
				# 0-4 ; 1-3; 2-2; 3-1; 4-0 -> end = 4-start
			if Network.is_host:
				Manager.switcheroo.rpc(old_card,temp_index, get_path(), 1)
			else:
				Manager.switcheroo.rpc(temp_index,old_card, get_path(), 2)
			get_tree().get_first_node_in_group("fightbar").panel_3.visible = false
			Manager.rpc("card_sender", multiplayer.get_unique_id(), "THEIF!")
			Manager.js_toggle_turn.rpc()
func _ask_to_switch(theirindex) -> void: 
	mayclick = true 
	old_card = theirindex
	get_tree().get_first_node_in_group("fightbar").show_other_card()

	


func _on_area_2d_mouse_entered() -> void:
	current = true


func _on_area_2d_mouse_exited() -> void:
	current = false
