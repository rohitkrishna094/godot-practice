extends CharacterBody2D


func _process(delta):
	var mouse_x = clamp(get_viewport().get_mouse_position().x, 0, get_viewport_rect().size.x)
	global_position.x = mouse_x
