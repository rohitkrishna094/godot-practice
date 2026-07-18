class_name BlockType
extends Resource

@export var id: String = "stone"
@export var name: String = "Stone"

@export var metallic: float = 0.0
@export var roughness: float = 1.0
@export var transparency: float = 0.0
@export var emission_color: Color = Color(0, 0, 0)
@export var emission_energy: float = 0.0

@export var top_texture: String = ""
@export var side_texture: String = ""
@export var bottom_texture: String = ""
@export var normal_map: String = ""

func get_texture_for_uv2(uv2: Vector2) -> String:
	if uv2.y > 0.5:
		return top_texture
	elif uv2.y < -0.5:
		return bottom_texture
	else:
		return side_texture

func is_transparent() -> bool:
	return transparency > 0.01

func is_emissive() -> bool:
	return emission_energy > 0.01

func uses_single_texture() -> bool:
	return top_texture == "" or (top_texture == side_texture and side_texture == bottom_texture)

func get_primary_texture() -> String:
	if side_texture != "":
		return side_texture
	if top_texture != "":
		return top_texture
	return ""
