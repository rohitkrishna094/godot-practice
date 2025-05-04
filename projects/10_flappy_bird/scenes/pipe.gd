extends Node2D

@export var speed := 150.0  # pixels/second

var player
var main
var score_counted = false
var pipe_width = 50
signal player_hit_pipe

func _process(delta):
	position.x -= speed * delta
	if not score_counted and player.position.x > position.x + pipe_width / 2:
		score_counted = true
		if main:
			main.increment_score()
	
	
	if position.x < -100:  # off-screen to the left
		queue_free()

func _on_body_entered(body):
	if body == player:
		player_hit_pipe.emit()
