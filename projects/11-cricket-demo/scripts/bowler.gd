extends Node3D

@export var ball_scene: PackedScene

@export var speed: float = 30.0
@export var direction_offset: float = 0.0 # left/right curve
@export var ball_type: String = "fast" # "fast" or "spin"

func _input(event):
	if event.is_action_pressed("ui_accept"):
		bowl_ball()

func bowl_ball():
	var ball = ball_scene.instantiate()
	get_tree().current_scene.add_child(ball)

	# Spawn ball at bowler hand height
	ball.global_position = global_position + Vector3(0, 1.5, 0)

	# Base direction toward batter
	var dir = -global_transform.basis.z
	dir.x += direction_offset  # swing/curve
	dir = dir.normalized()

	match ball_type:
		"fast":
			# Fast ball: high speed, minimal spin
			ball.linear_velocity = dir * speed
			ball.angular_velocity = Vector3.ZERO
		"spin":
			# Spin ball: slower, apply rotation
			ball.linear_velocity = dir * speed * 0.6
			# angular_velocity: Y rotation for offspin, small X for top spin
			ball.angular_velocity = Vector3(10, 30, 0)
