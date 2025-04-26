extends CharacterBody2D

@onready var label: Label = $"../Label"
@onready var fall_sfx_player: AudioStreamPlayer2D = $"../FallSfxPlayer"


func _physics_process(delta: float) -> void:
	global_position.x = get_viewport().get_mouse_position().x


func _on_area_2d_area_entered(area: Area2D) -> void:
	fall_sfx_player.play()
	var score = int(label.text)
	label.text = str(score + 1)
	area.queue_free()
