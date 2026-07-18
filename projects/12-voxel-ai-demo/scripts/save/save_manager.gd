extends Node

const SAVE_DIR := "user://saves/"
const SAVE_PREFIX := "save_"
const SAVE_EXT := ".json"
const MAX_SLOTS := 5

func _ready():
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_slot(slot: int, data: Dictionary) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		return false
	var path = SAVE_DIR + SAVE_PREFIX + str(slot) + SAVE_EXT
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return false
	file.store_line(JSON.stringify(data, "\t"))
	return true

func load_slot(slot: int) -> Dictionary:
	if slot < 0 or slot >= MAX_SLOTS:
		return {}
	var path = SAVE_DIR + SAVE_PREFIX + str(slot) + SAVE_EXT
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

func slot_exists(slot: int) -> bool:
	var path = SAVE_DIR + SAVE_PREFIX + str(slot) + SAVE_EXT
	return FileAccess.file_exists(path)

func get_slot_metadata(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {"exists": false, "timestamp": "", "block_count": 0}
	var data = load_slot(slot)
	return {
		"exists": true,
		"timestamp": data.get("timestamp", ""),
		"block_count": data.get("blocks", []).size()
	}