extends CharacterBody3D

#https://www.youtube.com/watch?v=EP5AYllgHy8&t=2009s&ab_channel=Lukky
@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $visual/mixamo_base/AnimationPlayer
@onready var visual: Node3D = $visual

var SPEED = 3.0
const JUMP_VELOCITY = 4.5
var isLocked = false

var sens_horizontal = 0.5
var sens_vertical = 0.5

var walk_speed = 3.0
var sprint_speed = 5.0
var running = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visual.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if !animation_player.is_playing():
		isLocked = false
	
	if Input.is_action_just_pressed("kick"):
		isLocked = true
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
	
	if Input.is_action_pressed("sprint"):
		running = true
		SPEED = sprint_speed
	else:
		running = false
		SPEED = walk_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !isLocked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			visual.look_at(position + direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !isLocked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !isLocked:
		move_and_slide()
