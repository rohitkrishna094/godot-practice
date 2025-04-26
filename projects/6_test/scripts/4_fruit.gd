extends Node2D

var speed := 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += speed * delta
	if global_position.y > get_viewport_rect().size.y:
		queue_free()
