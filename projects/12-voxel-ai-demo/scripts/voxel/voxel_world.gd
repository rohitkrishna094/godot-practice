class_name VoxelWorld
extends Node3D

var block_types := []
var _type_map := {}
var blocks := {}

func _ready():
	_load_block_types()
	new_world()

func _load_block_types():
	var dir = DirAccess.open("res://resources/blocks/")
	if not dir:
		return
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres") or file.ends_with(".res"):
			var res = load("res://resources/blocks/" + file)
			if res and res is BlockType:
				block_types.append(res)
				_type_map[res.id] = res
		file = dir.get_next()
	dir.list_dir_end()

func get_block_types() -> Array:
	return block_types.duplicate()

func get_block(pos: Vector3i):
	var entry = blocks.get(pos)
	return entry.type if entry else null

func place_block(pos: Vector3i, block_type: BlockType) -> bool:
	if pos in blocks:
		return false
	_create_block_at(pos, block_type)
	return true

func destroy_block(pos: Vector3i) -> bool:
	var entry = blocks.get(pos)
	if not entry:
		return false
	remove_child(entry.node)
	entry.node.queue_free()
	blocks.erase(pos)
	return true

func _make_material(albedo_tex: Texture2D, block_type: BlockType, normal_tex: Texture2D = null) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	if albedo_tex:
		mat.albedo_texture = albedo_tex
	else:
		mat.albedo_color = Color.WHITE
	mat.metallic = block_type.metallic
	mat.roughness = block_type.roughness
	if normal_tex:
		mat.normal_texture = normal_tex
	if block_type.is_transparent():
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if block_type.is_emissive():
		mat.emission_enabled = true
		mat.emission = block_type.emission_color
		mat.emission_energy_multiplier = block_type.emission_energy
	return mat

func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var res = load(path)
	return res if res is Texture2D else null

func _create_block_at(pos: Vector3i, block_type: BlockType):
	var block = StaticBody3D.new()
	block.position = Vector3(pos.x, pos.y, pos.z)
	block.set_meta(&"block_pos", pos)
	block.set_meta(&"block_type_id", block_type.id)

	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	block.add_child(collision)

	var mi = MeshInstance3D.new()
	var mesh = BoxMesh.new()

	var albedo = _load_texture(block_type.get_primary_texture())
	mesh.material = _make_material(albedo, block_type, _load_texture(block_type.normal_map))

	mi.mesh = mesh
	block.add_child(mi)

	add_child(block)
	blocks[pos] = {type = block_type, node = block}

func new_world():
	_clear_all()
	_generate_flat_terrain()

func _generate_flat_terrain():
	var grass = _type_map.get("grass")
	if not grass and block_types.size() > 0:
		grass = block_types[0]
	if not grass:
		return

	for x in range(-8, 9):
		for z in range(-8, 9):
			var pos = Vector3i(x, -1, z)
			_create_block_at(pos, grass)

	var types = block_types.duplicate()
	for x in range(-6, 7):
		for z in range(-6, 7):
			if randi() % 4 == 0:
				var pos = Vector3i(x, 0, z)
				_create_block_at(pos, types[randi() % types.size()])

func _clear_all():
	for entry in blocks.values():
		if is_instance_valid(entry.node):
			remove_child(entry.node)
			entry.node.queue_free()
	blocks.clear()

func get_data_for_save() -> Array:
	var data = []
	for pos in blocks:
		var bt = blocks[pos].type
		data.append({
			"x": pos.x,
			"y": pos.y,
			"z": pos.z,
			"type": bt.id
		})
	return data

func load_from_data(data: Array):
	_clear_all()
	for entry in data:
		var bt = _type_map.get(entry.type, block_types[0] if block_types.size() > 0 else null)
		if bt:
			var pos = Vector3i(entry.x, entry.y, entry.z)
			_create_block_at(pos, bt)

func serialize() -> Dictionary:
	return {
		"version": 1,
		"blocks": get_data_for_save()
	}

func deserialize(data: Dictionary):
	load_from_data(data.get("blocks", []))
