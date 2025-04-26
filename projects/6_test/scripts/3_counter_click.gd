extends Node2D


func _on_button_pressed() -> void:
	var score = int($Label.text) + 1
	$Label.text = str(score)
	
