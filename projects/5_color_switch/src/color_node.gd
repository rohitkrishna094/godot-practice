@tool
extends Sprite2D

class_name ColorNode

const COLORS := [Color("#32DBF0"),Color("#FF0181"),Color("#900DFF"),Color("#FAE100")]

@export_range(0, 3) var current_color: int = 0:
	set(new_val):
		current_color = new_val
		self_modulate = COLORS[current_color]

func _ready() -> void:
	self_modulate = COLORS[current_color]

func set_current_color(new_val: int) -> void:
	current_color = new_val
	self_modulate = COLORS[current_color]
