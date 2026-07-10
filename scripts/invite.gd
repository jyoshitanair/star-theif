extends Node2D
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.connection_established.connect(on_recived)
	Network.host_room()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func on_recived() -> void: 
	label.text = "connected"
