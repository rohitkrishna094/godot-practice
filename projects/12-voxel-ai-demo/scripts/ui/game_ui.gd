extends CanvasLayer

const GRID_COLS := 10
const SLOT_W := 90
const SLOT_H := 88
const SAVE_SLOTS := 5

@onready var player = get_node("/root/Main/Player")
@onready var world = get_node("/root/Main/World")
var block_types := []
var slots := []
var _grid_visible := true

@onready var grid: GridContainer = $Panel/ScrollContainer/Center/Grid
@onready var panel: Panel = $Panel
@onready var crosshair: Control = $Crosshair
@onready var dim: ColorRect = $Dim
@onready var save_menu: Panel = $SaveMenu
@onready var save_container: VBoxContainer = $SaveMenu/MarginContainer/VBoxContainer

func _ready():
	var sc = $Panel/ScrollContainer
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	sc.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	if player:
		block_types = player.block_types
		player.selection_changed.connect(_on_selection_changed)
	build_grid()
	dim.hide()
	save_menu.hide()

func _on_selection_changed(_index: int):
	update_grid()

func build_grid():
	for child in grid.get_children():
		child.queue_free()
	slots.clear()
	grid.columns = GRID_COLS

	for i in range(block_types.size()):
		var bt = block_types[i]

		var slot = PanelContainer.new()
		slot.custom_minimum_size = Vector2(SLOT_W, SLOT_H)

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vbox.add_theme_constant_override("separation", 2)

		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(64, 48)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var tex_path = bt.get_primary_texture()
		if tex_path:
			tex_rect.texture = load(tex_path)
		vbox.add_child(tex_rect)

		var label = Label.new()
		label.text = bt.name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(SLOT_W, 20)
		label.add_theme_font_size_override("font_size", 9)
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		if bt.name.length() > 6:
			label.add_theme_font_size_override("font_size", 8)
		vbox.add_child(label)

		slot.add_child(vbox)
		grid.add_child(slot)
		slots.append(slot)

	update_grid()

func update_grid():
	if not is_instance_valid(player):
		return
	var sel = player.selected_block_index
	for i in range(slots.size()):
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 3
		style.corner_radius_top_right = 3
		style.corner_radius_bottom_left = 3
		style.corner_radius_bottom_right = 3

		if i == sel:
			style.bg_color = Color(0.2, 0.2, 0.2, 0.75)
			style.set_border_width_all(3)
			style.border_color = Color(1, 0.85, 0.2)
			style.shadow_color = Color(1, 0.85, 0.2, 0.4)
			style.shadow_size = 6
		else:
			style.bg_color = Color(0.2, 0.2, 0.2, 0.75)
			style.set_border_width_all(1)
			style.border_color = Color(0.5, 0.5, 0.5, 0.6)

		slots[i].add_theme_stylebox_override("panel", style)

func _toggle_grid():
	_grid_visible = not _grid_visible
	panel.visible = _grid_visible

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if save_menu.visible:
			_hide_save_menu()
		else:
			_show_save_menu()
	if event.is_action_pressed("toggle_block_grid"):
		_toggle_grid()

func _show_save_menu():
	save_menu.show()
	dim.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_save_slots()

func _hide_save_menu():
	save_menu.hide()
	dim.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _refresh_save_slots():
	for child in save_container.get_children():
		child.queue_free()

	for i in range(SAVE_SLOTS):
		var meta = SaveManager.get_slot_metadata(i)
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var label = Label.new()
		if meta.exists:
			label.text = "Slot %d — %d blocks" % [i + 1, meta.block_count]
		else:
			label.text = "Slot %d — Empty" % [i + 1]
		label.custom_minimum_size = Vector2(200, 0)

		var save_btn = Button.new()
		save_btn.text = "Save"
		save_btn.pressed.connect(_on_save.bind(i))

		var load_btn = Button.new()
		load_btn.text = "Load"
		load_btn.disabled = not meta.exists
		load_btn.pressed.connect(_on_load.bind(i))

		hbox.add_child(label)
		hbox.add_child(save_btn)
		hbox.add_child(load_btn)
		save_container.add_child(hbox)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	save_container.add_child(spacer)

	var close_btn = Button.new()
	close_btn.text = "Resume Game"
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(_hide_save_menu)
	save_container.add_child(close_btn)

func _on_save(slot: int):
	if not is_instance_valid(world):
		return
	var data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"blocks": world.get_data_for_save()
	}
	SaveManager.save_slot(slot, data)
	_refresh_save_slots()

func _on_load(slot: int):
	if not is_instance_valid(world):
		return
	var data = SaveManager.load_slot(slot)
	world.load_from_data(data.get("blocks", []))
	_hide_save_menu()