class_name Player
extends CharacterBody3D

@export var mouse_sensitivity := 0.002
@export var walk_speed := 5.0
@export var sprint_speed := 8.0
@export var jump_velocity := 4.5
@export var fly_speed := 10.0

var gravity: float
var selected_block_index := 0
var block_types := []
var _flying := false
var _jumps_remaining := 0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/BlockPicker
@onready var world: VoxelWorld = get_node("/root/Main/World")

func _ready():
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if world:
		block_types = world.get_block_types()

signal selection_changed(index: int)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)

	if event.is_action_pressed("ui_cancel"):
		return

	if event.is_action_pressed("toggle_flight"):
		_flying = not _flying
		if _flying:
			velocity.y = 0

	var prev = selected_block_index
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and block_types.size() > 0:
			selected_block_index = (selected_block_index + 1) % block_types.size()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and block_types.size() > 0:
			selected_block_index = (selected_block_index - 1 + block_types.size()) % block_types.size()

	for i in range(min(block_types.size(), 9)):
		if event.is_action_pressed("hotbar_" + str(i + 1)):
			selected_block_index = i
	if selected_block_index != prev:
		selection_changed.emit(selected_block_index)

func _physics_process(delta):
	if _flying:
		velocity.y = 0
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var speed = fly_speed if Input.is_action_pressed("sprint") else walk_speed
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_pressed("jump"):
			velocity.y = fly_speed
		if Input.is_action_pressed("sprint"):
			velocity.y = -fly_speed
		move_and_slide()
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		_handle_block_interaction()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_on_floor():
		_jumps_remaining = 2

	if Input.is_action_just_pressed("jump") and _jumps_remaining > 0:
		velocity.y = jump_velocity
		_jumps_remaining -= 1

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	_handle_block_interaction()

func _handle_block_interaction():
	if not raycast.is_colliding():
		return

	var collider = raycast.get_collider()
	var normal = raycast.get_collision_normal()

	if Input.is_action_just_pressed("destroy_block"):
		if collider.has_meta(&"block_pos"):
			world.destroy_block(collider.get_meta(&"block_pos"))

	if Input.is_action_just_pressed("place_block"):
		if collider.has_meta(&"block_pos") and block_types.size() > 0:
			var hit_pos = Vector3i(
				collider.get_meta(&"block_pos").x + roundi(normal.x),
				collider.get_meta(&"block_pos").y + roundi(normal.y),
				collider.get_meta(&"block_pos").z + roundi(normal.z)
			)
			world.place_block(hit_pos, block_types[selected_block_index])
