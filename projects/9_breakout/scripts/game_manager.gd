extends Node2D

var score = 0
var level = 1

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var level_label: Label = $CanvasLayer/LevelLabel

func addPoints(points):
	score += points

func _process(delta: float) -> void:
	score_label.text = "Score: " + str(score)
	level_label.text = "Level: " + str(level)
