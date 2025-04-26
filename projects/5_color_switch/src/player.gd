extends CharacterBody2D

@export var jump_speed: int = 1250
@export var gravity: int = 2500


func _physics_process(delta: float) -> void:
	velocity.y += Vector2.DOWN.y * gravity * delta
	velocity.x = 0
	
	move_and_slide()
