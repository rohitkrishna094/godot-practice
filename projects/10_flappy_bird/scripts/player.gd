extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var gravity: float = 900
@export var jump_speed: float = 100
@export var rotation_speed: float = 15.0

func _ready() -> void:
	animated_sprite_2d.play("birdFlap")

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = 0

	if Input.is_action_pressed("jump"):
		velocity.y = -jump_speed
	
	move_and_slide()
	
	 # Tilt based on vertical speed
	var target_rotation = clamp(velocity.y / 300.0, -1.0, 1.0) * deg_to_rad(15)
	rotation = lerp(rotation, target_rotation, rotation_speed * delta)
