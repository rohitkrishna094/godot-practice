extends Node2D

var screen_size
var pad_size
var direction = Vector2(1, 0)

const INITIAL_BALL_SPEED = 150
var ball_speed = INITIAL_BALL_SPEED
const PAD_SPEED = 200

func _ready():
	screen_size = get_viewport().size
	pad_size = $"left".get_texture().get_size()
	print(pad_size)
	set_process(true)

func _process(delta: float) -> void:
	var ball_pos = $ball.position
	var left_rect = Rect2($left.position - pad_size * 0.5, pad_size)
	var right_rect = Rect2($right.position - pad_size * 0.5, pad_size)
	
	ball_pos += direction * ball_speed * delta
	
	if ((ball_pos.y < 0 and direction.y < 0) or (ball_pos.y > screen_size.y and direction.y > 0)):
		direction.y *= -1
	
	if ( (left_rect.has_point(ball_pos) and direction.x < 0) or (right_rect.has_point(ball_pos) and direction.x > 0) ):
		direction.x *= -1
		direction.y = randf() * 2 - 1
		direction = direction.normalized()
		ball_speed *= 1.1
	
	# Check gameover
	if (ball_pos.x < 0 or ball_pos.x > screen_size.x):
		ball_pos = screen_size * 0.5
		ball_speed = INITIAL_BALL_SPEED
		direction = Vector2(-1, 0)
	
	$ball.position = ball_pos
	
	move_pad("left", "left_move_up", "left_move_down", delta)
	move_pad("right", "right_move_up", "right_move_down", delta)
		

func move_pad(pad_name, move_up_action, move_down_action, delta):
	var pad_pos = get_node(pad_name).position
	
	if pad_pos.y > 0 and Input.is_action_pressed(move_up_action) :
		pad_pos.y -= PAD_SPEED * delta
	if pad_pos.y < screen_size.y and Input.is_action_pressed(move_down_action) :
		pad_pos.y += PAD_SPEED * delta
	
	get_node(pad_name).position = pad_pos
	
