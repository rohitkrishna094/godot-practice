extends Node2D

@export var apple_texture: Texture2D
@export var orange_texture: Texture2D
@export var strawberry_texture: Texture2D

var speed := 100.0
var sprite: Sprite2D

func get_random_texture():
	return [apple_texture, orange_texture, strawberry_texture].pick_random()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_fruit():
	var fruit = Node2D.new()
	var sprite = Sprite2D.new()
	var currentTexture = get_random_texture()
	sprite.texture = currentTexture
	sprite.centered = true
	sprite.position = Vector2.ZERO

	if(currentTexture == orange_texture):
		sprite.scale = Vector2(2,2)
	fruit.add_child(sprite)
	fruit.position.x = randf_range(0.0, get_viewport_rect().size.x)

	var speed = randf_range(100.0, 300.0)

	fruit.set_script(load("res://scripts/4_fruit.gd"))  # Attach behavior
	fruit.speed = speed  # Pass speed to script

	add_child(fruit)


func _on_fruit_timer_timeout() -> void:
	spawn_fruit()
