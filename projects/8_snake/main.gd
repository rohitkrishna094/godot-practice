extends Node2D

@export var grid_size: int = 36  # Match this with your snake's grid size
@export var grid_color: Color = Color(0.2, 0.2, 0.2, 0.5)  
@export var food_color: Color = Color(1, 0, 0)  # red
@export var snake_color: Color = Color(0.4, 0, 0, 1) 
@export var stroke_color: Color = Color(0.4, 0, 0, 1) 
@export var move_interval: float = 0.1  # Snake moves every few seconds

@onready var score_label: Label = $ScoreLabel
@onready var restart_label: Label = $RestartLabel  # Label for restarting the game (visible after game over)
@onready var eat_audio: AudioStreamPlayer2D = $EatAudio
@onready var game_over_audio: AudioStreamPlayer2D = $GameOverAudio
@onready var background_audio: AudioStreamPlayer2D = $BackgroundAudio

const width = 1
var snake_body: Array[Vector2]
var direction: Vector2   # initial direction
var move_timer: float = 0.0
var food_pos: Vector2 #Initial position at grid
var screen_size
var game_over: bool = false  # Track whether the game is over

func init() -> void:
	# Reset game state to start a new game
	snake_body = [Vector2(5, 5)]
	direction = Vector2.RIGHT
	score_label.text = "Score: 0"
	_spawn_food()
	game_over = false
	restart_label.visible = false
	background_audio.play()

func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_size.y -= grid_size
	init()

func _process(delta: float) -> void:
	if game_over:
		# Check for restart input even if the game is over
		if Input.is_action_pressed("restart"):
			init()
		return  # Don't update game logic if the game is over
	
	_handle_input()
	
	move_timer += delta
	if move_timer >= move_interval:
		move_timer = 0.0
		_move_snake()

	queue_redraw()

func _draw() -> void:
	# Draw grid lines, add grid_size on y to push rows down. Top row will be used for score
	for i in range(0, int(max(screen_size.x, screen_size.y)), grid_size):
		if i < screen_size.x:  # Draw vertical lines
			draw_line(Vector2(i, grid_size), Vector2(i, screen_size.y + grid_size), grid_color, width)
		if i < screen_size.y:  # Draw horizontal lines
			draw_line(Vector2(0, i + grid_size), Vector2(screen_size.x, i + grid_size), grid_color, width)

	
	# draw food
	draw_rect(
		Rect2(Vector2(food_pos.x * grid_size, food_pos.y * grid_size + grid_size), Vector2(grid_size, grid_size)), 
		food_color
	)
	
	# draw snake
	for part in snake_body:
		var rect = Rect2(Vector2(part.x * grid_size, part.y * grid_size + grid_size), Vector2(grid_size, grid_size))
		draw_rect(rect, snake_color)
		draw_rect(rect, stroke_color, false)

	if game_over:
		draw_string(ThemeDB.fallback_font, Vector2(screen_size.x / 2 - 100, screen_size.y / 2), "Game Over")
		draw_string(ThemeDB.fallback_font, Vector2(screen_size.x / 2 - 100, screen_size.y / 2 + 30), "Press R to Restart")


func _handle_input() -> void:
	if game_over:
		return
	if Input.is_action_pressed("up") and direction != Vector2.DOWN:
		direction = Vector2.UP
	elif Input.is_action_pressed("down") and direction != Vector2.UP:
		direction = Vector2.DOWN
	elif Input.is_action_pressed("left") and direction != Vector2.RIGHT:
		direction = Vector2.LEFT
	elif Input.is_action_pressed("right") and direction != Vector2.LEFT:
		direction = Vector2.RIGHT

func _spawn_food() -> void:
	# Build a list of all available (free) grid positions
	var available_positions: Array[Vector2] = []
	for x in range(int(screen_size.x / grid_size)):
		for y in range(int(screen_size.y / grid_size)):
			var pos = Vector2(x, y)
			if not pos in snake_body:
				available_positions.append(pos)
	
	if available_positions.size() > 0:
		food_pos = available_positions.pick_random()
	else:
		print("No available space to spawn food!")

func _move_snake() -> void:
	var new_head: Vector2 = snake_body[0] + direction # Compute new head position
	# Check for wall collisions (head out of bounds)
	if new_head.x < 0 or new_head.x >= int(screen_size.x / grid_size) or new_head.y < 0 or new_head.y >= int(screen_size.y / grid_size):
		_game_over()
		return

	# Check for self-collision (head collides with body)
	if new_head in snake_body:
		_game_over()
		return
	
	snake_body.insert(0, new_head) # Insert it at the front of the array
	# Remove the last element (unless you’re growing)
	if new_head != food_pos:
		snake_body.pop_back()
	else:
		# eat food
		var current_score = int(score_label.text.split(": ")[1]) + 1
		score_label.text = "Score: " + str(current_score)
		_spawn_food()
		eat_audio.play()

func _game_over() -> void:
	background_audio.stop()
	game_over_audio.play()
	game_over = true
	restart_label.visible = true  # Show the restart label
