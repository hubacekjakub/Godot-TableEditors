@tool
extends Control
## Phase 1 comparison: 3 approaches for table editing in a Godot editor plugin.
## Run this scene in the EDITOR (not standalone) to see all approaches.
##
## Tab A: Tree (native widget, limited cell modes)
## Tab B: GridContainer + basic controls (SpinBox, LineEdit, CheckBox)
## Tab C: GridContainer + native Editor controls (EditorSpinSlider, EditorResourcePicker)
##
## NOTE: Tab C uses editor-only classes. Must run inside the Godot editor.

# ── Sample schema & data ──────────────────────────────────────────────

const COLUMNS: Array[Dictionary] = [
	{ "name": "name",     "type": TYPE_STRING,  "default": "" },
	{ "name": "hp",       "type": TYPE_INT,     "default": 100 },
	{ "name": "speed",    "type": TYPE_FLOAT,   "default": 1.0 },
	{ "name": "is_boss",  "type": TYPE_BOOL,    "default": false },
	{ "name": "position", "type": TYPE_VECTOR2, "default": Vector2.ZERO },
	{ "name": "offset3d", "type": TYPE_VECTOR3, "default": Vector3.ZERO },
	{ "name": "scene",    "type": TYPE_OBJECT,  "default": null, "hint": "PackedScene" },
	{ "name": "icon",     "type": TYPE_OBJECT,  "default": null, "hint": "Texture2D" },
]

var _icon_texture: Texture2D = null

var ROWS: Array[Dictionary] = [
	{ "name": "Knight",  "hp": 120, "speed": 1.0,  "is_boss": false, "position": Vector2(10, 20),    "offset3d": Vector3(1, 0, 0),    "scene": null, "icon": null },
	{ "name": "Archer",  "hp": 80,  "speed": 1.8,  "is_boss": false, "position": Vector2(50, 30),    "offset3d": Vector3(0, 1, 0),    "scene": null, "icon": null },
	{ "name": "Mage",    "hp": 65,  "speed": 1.2,  "is_boss": false, "position": Vector2(100, 0),    "offset3d": Vector3(0, 0, 1),    "scene": null, "icon": null },
	{ "name": "Dragon",  "hp": 500, "speed": 0.7,  "is_boss": true,  "position": Vector2(200, 150),  "offset3d": Vector3(5, 10, -3),  "scene": null, "icon": null },
	{ "name": "Goblin",  "hp": 30,  "speed": 2.5,  "is_boss": false, "position": Vector2(-10, 40),   "offset3d": Vector3(0, 0, 0),    "scene": null, "icon": null },
	{ "name": "Lich",    "hp": 300, "speed": 0.9,  "is_boss": true,  "position": Vector2(0, -100),   "offset3d": Vector3(3, 3, 3),    "scene": null, "icon": null },
]


func _ready() -> void:
	if ResourceLoader.exists("res://icon.svg"):
		_icon_texture = load("res://icon.svg")
		ROWS[3]["icon"] = _icon_texture
		ROWS[5]["icon"] = _icon_texture

	var tabs := TabContainer.new()
	tabs.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(tabs)

	# ── Tab A: Tree ───────────────────────────────────────────────────
	var tree_container := VBoxContainer.new()
	tree_container.name = "A: Tree (native)"
	tabs.add_child(tree_container)
	var tree := _build_tree_grid()
	tree.size_flags_vertical = SIZE_EXPAND_FILL
	tree_container.add_child(tree)

	# ── Tab B: GridContainer + basic controls ─────────────────────────
	var grid_basic_container := VBoxContainer.new()
	grid_basic_container.name = "B: Grid + basic controls"
	tabs.add_child(grid_basic_container)
	var scroll_b := ScrollContainer.new()
	scroll_b.size_flags_vertical = SIZE_EXPAND_FILL
	scroll_b.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll_b.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	grid_basic_container.add_child(scroll_b)
	scroll_b.add_child(_build_grid_basic())

	# ── Tab C: GridContainer + native Editor* controls ────────────────
	var grid_native_container := VBoxContainer.new()
	grid_native_container.name = "C: Grid + Editor* controls"
	tabs.add_child(grid_native_container)
	if Engine.is_editor_hint():
		var scroll_c := ScrollContainer.new()
		scroll_c.size_flags_vertical = SIZE_EXPAND_FILL
		scroll_c.size_flags_horizontal = SIZE_EXPAND_FILL
		scroll_c.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		grid_native_container.add_child(scroll_c)
		scroll_c.add_child(_build_grid_native())
	else:
		var lbl := Label.new()
		lbl.text = "Editor* controls only available when running inside the editor."
		grid_native_container.add_child(lbl)


# ══════════════════════════════════════════════════════════════════════
#  APPROACH A — Tree
# ══════════════════════════════════════════════════════════════════════

func _build_tree_grid() -> Tree:
	var tree := Tree.new()
	tree.columns = COLUMNS.size()
	tree.column_titles_visible = true
	tree.hide_root = true
	tree.allow_reselect = true
	tree.select_mode = Tree.SELECT_ROW

	for col_idx: int in COLUMNS.size():
		var col: Dictionary = COLUMNS[col_idx]
		tree.set_column_title(col_idx, col["name"])
		tree.set_column_expand(col_idx, true)
		tree.set_column_clip_content(col_idx, false)

	var root: TreeItem = tree.create_item()
	for row: Dictionary in ROWS:
		var item: TreeItem = tree.create_item(root)
		for col_idx: int in COLUMNS.size():
			var col: Dictionary = COLUMNS[col_idx]
			var value: Variant = row.get(col["name"], col["default"])
			_set_tree_cell(item, col_idx, col["type"], value, col)

	tree.item_edited.connect(_on_tree_item_edited.bind(tree))
	return tree


func _set_tree_cell(item: TreeItem, col: int, type: int, value: Variant, col_meta: Dictionary = {}) -> void:
	match type:
		TYPE_STRING:
			item.set_cell_mode(col, TreeItem.CELL_MODE_STRING)
			item.set_text(col, str(value))
			item.set_editable(col, true)
		TYPE_INT:
			item.set_cell_mode(col, TreeItem.CELL_MODE_RANGE)
			item.set_range_config(col, 0, 9999, 1)
			item.set_range(col, value)
			item.set_editable(col, true)
		TYPE_FLOAT:
			item.set_cell_mode(col, TreeItem.CELL_MODE_RANGE)
			item.set_range_config(col, 0.0, 9999.0, 0.1)
			item.set_range(col, value)
			item.set_editable(col, true)
		TYPE_BOOL:
			item.set_cell_mode(col, TreeItem.CELL_MODE_CHECK)
			item.set_checked(col, value)
			item.set_text(col, "")
			item.set_editable(col, true)
		TYPE_VECTOR2:
			item.set_cell_mode(col, TreeItem.CELL_MODE_STRING)
			var v: Vector2 = value if value is Vector2 else Vector2.ZERO
			item.set_text(col, "(%s, %s)" % [v.x, v.y])
			item.set_editable(col, true)
		TYPE_VECTOR3:
			item.set_cell_mode(col, TreeItem.CELL_MODE_STRING)
			var v: Vector3 = value if value is Vector3 else Vector3.ZERO
			item.set_text(col, "(%s, %s, %s)" % [v.x, v.y, v.z])
			item.set_editable(col, true)
		TYPE_OBJECT:
			var hint: String = col_meta.get("hint", "")
			if hint == "Texture2D" and value is Texture2D:
				item.set_icon(col, value)
				item.set_icon_max_width(col, 24)
				item.set_text(col, value.resource_path.get_file())
			elif value is Resource:
				item.set_text(col, value.resource_path.get_file() if value.resource_path else "<resource>")
			else:
				item.set_text(col, "<empty>")
			item.set_editable(col, false)


func _on_tree_item_edited(tree: Tree) -> void:
	var item: TreeItem = tree.get_edited()
	var col: int = tree.get_edited_column()
	if item == null:
		return
	var col_meta: Dictionary = COLUMNS[col]
	match col_meta["type"]:
		TYPE_STRING:
			print("[Tree] (%d,%d) = %s" % [item.get_index(), col, item.get_text(col)])
		TYPE_INT, TYPE_FLOAT:
			print("[Tree] (%d,%d) = %s" % [item.get_index(), col, item.get_range(col)])
		TYPE_BOOL:
			print("[Tree] (%d,%d) = %s" % [item.get_index(), col, item.is_checked(col)])
		TYPE_VECTOR2, TYPE_VECTOR3:
			print("[Tree] (%d,%d) = %s" % [item.get_index(), col, item.get_text(col)])


# ══════════════════════════════════════════════════════════════════════
#  APPROACH B — GridContainer + basic controls (SpinBox, LineEdit, etc.)
# ══════════════════════════════════════════════════════════════════════

func _build_grid_basic() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = COLUMNS.size()
	grid.size_flags_horizontal = SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)

	for col: Dictionary in COLUMNS:
		var header := Button.new()
		header.text = col["name"]
		header.flat = true
		header.disabled = true
		header.size_flags_horizontal = SIZE_EXPAND_FILL
		header.custom_minimum_size.x = 100
		grid.add_child(header)

	for row_idx: int in ROWS.size():
		var row: Dictionary = ROWS[row_idx]
		for col_idx: int in COLUMNS.size():
			var col: Dictionary = COLUMNS[col_idx]
			var value: Variant = row.get(col["name"], col["default"])
			var ctrl: Control = _create_basic_cell(row_idx, col_idx, col["type"], value, col)
			ctrl.size_flags_horizontal = SIZE_EXPAND_FILL
			ctrl.custom_minimum_size.x = 100
			grid.add_child(ctrl)
	return grid


func _create_basic_cell(row: int, col: int, type: int, value: Variant, col_meta: Dictionary = {}) -> Control:
	match type:
		TYPE_STRING:
			var edit := LineEdit.new()
			edit.text = str(value)
			edit.text_submitted.connect(func(t: String) -> void: print("[Basic] (%d,%d) = %s" % [row, col, t]))
			return edit
		TYPE_INT:
			var spin := SpinBox.new()
			spin.min_value = 0; spin.max_value = 9999; spin.step = 1; spin.value = value
			spin.value_changed.connect(func(v: float) -> void: print("[Basic] (%d,%d) = %d" % [row, col, int(v)]))
			return spin
		TYPE_FLOAT:
			var spin := SpinBox.new()
			spin.min_value = 0.0; spin.max_value = 9999.0; spin.step = 0.1; spin.value = value
			spin.value_changed.connect(func(v: float) -> void: print("[Basic] (%d,%d) = %s" % [row, col, v]))
			return spin
		TYPE_BOOL:
			var check := CheckBox.new()
			check.button_pressed = value
			check.toggled.connect(func(p: bool) -> void: print("[Basic] (%d,%d) = %s" % [row, col, p]))
			return check
		TYPE_VECTOR2:
			var v: Vector2 = value if value is Vector2 else Vector2.ZERO
			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 2)
			var sx := SpinBox.new()
			sx.min_value = -9999; sx.max_value = 9999; sx.step = 0.1; sx.value = v.x; sx.prefix = "x:"
			sx.size_flags_horizontal = SIZE_EXPAND_FILL
			var sy := SpinBox.new()
			sy.min_value = -9999; sy.max_value = 9999; sy.step = 0.1; sy.value = v.y; sy.prefix = "y:"
			sy.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(sx); hbox.add_child(sy)
			sx.value_changed.connect(func(_v: float) -> void: print("[Basic] (%d,%d) = Vec2(%s,%s)" % [row, col, sx.value, sy.value]))
			sy.value_changed.connect(func(_v: float) -> void: print("[Basic] (%d,%d) = Vec2(%s,%s)" % [row, col, sx.value, sy.value]))
			return hbox
		TYPE_VECTOR3:
			var v: Vector3 = value if value is Vector3 else Vector3.ZERO
			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 2)
			var sx := SpinBox.new()
			sx.min_value = -9999; sx.max_value = 9999; sx.step = 0.1; sx.value = v.x; sx.prefix = "x:"
			sx.size_flags_horizontal = SIZE_EXPAND_FILL
			var sy := SpinBox.new()
			sy.min_value = -9999; sy.max_value = 9999; sy.step = 0.1; sy.value = v.y; sy.prefix = "y:"
			sy.size_flags_horizontal = SIZE_EXPAND_FILL
			var sz := SpinBox.new()
			sz.min_value = -9999; sz.max_value = 9999; sz.step = 0.1; sz.value = v.z; sz.prefix = "z:"
			sz.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(sx); hbox.add_child(sy); hbox.add_child(sz)
			sx.value_changed.connect(func(_v: float) -> void: print("[Basic] (%d,%d) = Vec3(%s,%s,%s)" % [row, col, sx.value, sy.value, sz.value]))
			sy.value_changed.connect(func(_v: float) -> void: print("[Basic] (%d,%d) = Vec3(%s,%s,%s)" % [row, col, sx.value, sy.value, sz.value]))
			sz.value_changed.connect(func(_v: float) -> void: print("[Basic] (%d,%d) = Vec3(%s,%s,%s)" % [row, col, sx.value, sy.value, sz.value]))
			return hbox
		TYPE_OBJECT:
			var hint: String = col_meta.get("hint", "")
			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 4)
			if hint == "Texture2D" and value is Texture2D:
				var rect := TextureRect.new()
				rect.texture = value
				rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
				rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				rect.custom_minimum_size = Vector2(24, 24)
				hbox.add_child(rect)
			var path_label := Label.new()
			path_label.text = value.resource_path.get_file() if value is Resource and value.resource_path else "<empty>"
			path_label.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(path_label)
			var btn := Button.new()
			btn.text = "..."
			btn.tooltip_text = "Browse %s" % hint
			btn.pressed.connect(func() -> void: print("[Basic] (%d,%d) browse %s" % [row, col, hint]))
			hbox.add_child(btn)
			return hbox
	var lbl := Label.new()
	lbl.text = str(value)
	return lbl


# ══════════════════════════════════════════════════════════════════════
#  APPROACH C — GridContainer + native Editor* controls
#  Uses: EditorSpinSlider (int/float/vector), EditorResourcePicker (resources)
#  These look EXACTLY like Godot's Inspector controls.
# ══════════════════════════════════════════════════════════════════════

func _build_grid_native() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = COLUMNS.size()
	grid.size_flags_horizontal = SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)

	for col: Dictionary in COLUMNS:
		var header := Button.new()
		header.text = col["name"]
		header.flat = true
		header.disabled = true
		header.size_flags_horizontal = SIZE_EXPAND_FILL
		header.custom_minimum_size.x = 120
		grid.add_child(header)

	for row_idx: int in ROWS.size():
		var row: Dictionary = ROWS[row_idx]
		for col_idx: int in COLUMNS.size():
			var col: Dictionary = COLUMNS[col_idx]
			var value: Variant = row.get(col["name"], col["default"])
			var ctrl: Control = _create_native_cell(row_idx, col_idx, col["type"], value, col)
			ctrl.size_flags_horizontal = SIZE_EXPAND_FILL
			ctrl.custom_minimum_size.x = 120
			grid.add_child(ctrl)
	return grid


func _create_native_cell(row: int, col: int, type: int, value: Variant, col_meta: Dictionary = {}) -> Control:
	match type:
		TYPE_STRING:
			var edit := LineEdit.new()
			edit.text = str(value)
			edit.text_submitted.connect(func(t: String) -> void: print("[Native] (%d,%d) = %s" % [row, col, t]))
			return edit
		TYPE_INT:
			var slider := EditorSpinSlider.new()
			slider.min_value = 0; slider.max_value = 9999; slider.step = 1
			slider.value = value
			slider.editing_integer = true
			slider.value_changed.connect(func(v: float) -> void: print("[Native] (%d,%d) = %d" % [row, col, int(v)]))
			return slider
		TYPE_FLOAT:
			var slider := EditorSpinSlider.new()
			slider.min_value = 0.0; slider.max_value = 9999.0; slider.step = 0.01
			slider.value = value
			slider.value_changed.connect(func(v: float) -> void: print("[Native] (%d,%d) = %s" % [row, col, v]))
			return slider
		TYPE_BOOL:
			var check := CheckBox.new()
			check.button_pressed = value
			check.toggled.connect(func(p: bool) -> void: print("[Native] (%d,%d) = %s" % [row, col, p]))
			return check
		TYPE_VECTOR2:
			var v: Vector2 = value if value is Vector2 else Vector2.ZERO
			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 4)
			var sx := EditorSpinSlider.new()
			sx.label = "x"; sx.min_value = -9999; sx.max_value = 9999; sx.step = 0.01; sx.value = v.x
			sx.size_flags_horizontal = SIZE_EXPAND_FILL
			var sy := EditorSpinSlider.new()
			sy.label = "y"; sy.min_value = -9999; sy.max_value = 9999; sy.step = 0.01; sy.value = v.y
			sy.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(sx); hbox.add_child(sy)
			sx.value_changed.connect(func(_v: float) -> void: print("[Native] (%d,%d) = Vec2(%s,%s)" % [row, col, sx.value, sy.value]))
			sy.value_changed.connect(func(_v: float) -> void: print("[Native] (%d,%d) = Vec2(%s,%s)" % [row, col, sx.value, sy.value]))
			return hbox
		TYPE_VECTOR3:
			var v: Vector3 = value if value is Vector3 else Vector3.ZERO
			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 4)
			var sx := EditorSpinSlider.new()
			sx.label = "x"; sx.min_value = -9999; sx.max_value = 9999; sx.step = 0.01; sx.value = v.x
			sx.size_flags_horizontal = SIZE_EXPAND_FILL
			var sy := EditorSpinSlider.new()
			sy.label = "y"; sy.min_value = -9999; sy.max_value = 9999; sy.step = 0.01; sy.value = v.y
			sy.size_flags_horizontal = SIZE_EXPAND_FILL
			var sz := EditorSpinSlider.new()
			sz.label = "z"; sz.min_value = -9999; sz.max_value = 9999; sz.step = 0.01; sz.value = v.z
			sz.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(sx); hbox.add_child(sy); hbox.add_child(sz)
			sx.value_changed.connect(func(_v: float) -> void: print("[Native] (%d,%d) = Vec3(%s,%s,%s)" % [row, col, sx.value, sy.value, sz.value]))
			sy.value_changed.connect(func(_v: float) -> void: print("[Native] (%d,%d) = Vec3(%s,%s,%s)" % [row, col, sx.value, sy.value, sz.value]))
			sz.value_changed.connect(func(_v: float) -> void: print("[Native] (%d,%d) = Vec3(%s,%s,%s)" % [row, col, sx.value, sy.value, sz.value]))
			return hbox
		TYPE_OBJECT:
			# EditorResourcePicker — the EXACT same control as Inspector uses
			var hint: String = col_meta.get("hint", "")
			var picker := EditorResourcePicker.new()
			picker.base_type = hint  # "PackedScene", "Texture2D", etc.
			if value is Resource:
				picker.edited_resource = value
			picker.resource_changed.connect(
				func(res: Resource) -> void:
					var path: String = res.resource_path if res else "<null>"
					print("[Native] (%d,%d) = %s: %s" % [row, col, hint, path])
			)
			return picker
	var lbl := Label.new()
	lbl.text = str(value)
	return lbl
