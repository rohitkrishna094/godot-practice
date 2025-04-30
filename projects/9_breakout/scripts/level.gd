# Tutorial from https://www.youtube.com/watch?v=IYjRhcOCFDo

extends Node2D

@export var brickObj: PackedScene
var cols = 32
var rows = 2
var margin = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupLevel()
	
func setupLevel():
	rows = min(9, 2 + GameManager.level)
	for r in rows:
		for c in cols:
			if randi_range(0, 2) >= 1:
				var newBrick = brickObj.instantiate()
				add_child(newBrick)
				newBrick.position = Vector2(margin + 34 * c, margin + 34 * r)
				
				var sprite = newBrick.get_node("Sprite2D")
				sprite.modulate = randomColor()

func randomColor() -> Color:
	return Color.from_hsv(randf(), randf_range(0.2, 0.6), randf_range(0.9, 1.0))
