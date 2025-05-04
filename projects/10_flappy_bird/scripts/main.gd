extends Node2D


@export var pipe_scene: PackedScene
@export var spawn_x := 1400  # spawn point off-screen right
@export var min_y := 135
@export var max_y := 530
@onready var parallax_background: ParallaxBackground = $ParallaxBackground
@onready var score_label: Label = $ScoreLabel
@onready var player: CharacterBody2D = $Player

var score := 0

func _on_PipeTimer_timeout():
	var pipe = pipe_scene.instantiate()
	pipe.position = Vector2(spawn_x, randf_range(min_y, max_y))
	pipe.player = player
	pipe.main = self
	add_child(pipe)
	

func _process(delta: float) -> void:
	parallax_background.scroll_offset.x -= 50 * delta

func increment_score():
	score += 1
	score_label.text = str(score)
