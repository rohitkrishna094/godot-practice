extends Node2D

@export var fall_speed : float = 200  # Speed of the fruit falling
var screen_size : Vector2

@onready var sprite = $Sprite2D

@export var textures: Array[Texture2D]  # Drag your textures here in the editor

func _ready():
	fall_speed = randf_range(150, 500) 
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Hide the cursor
	screen_size = get_viewport().size
	position.x = randf_range(0, screen_size.x)  # Spawn fruit at random X position
	position.y = -20  # Start above the screen
	
	if textures.size() > 0:
		var chosen_texture = textures.pick_random()
		sprite.texture = chosen_texture
		if chosen_texture.resource_path.ends_with("orange.png"):
			sprite.scale = Vector2(2, 2)


func _process(delta):
	position.y += fall_speed * delta  # Move the fruit downwards each frame
	
	if position.y > screen_size.y:  # If the fruit goes off the screen
		queue_free()  # Remove the fruit (or reset it)
