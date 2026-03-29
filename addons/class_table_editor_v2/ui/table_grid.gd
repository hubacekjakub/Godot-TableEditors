@tool
class_name TableGrid
extends VBoxContainer
## Editable grid backed by a ClassTableResourceV2.
## Uses GridContainer + native Editor* controls (EditorSpinSlider, EditorResourcePicker).

signal cell_edited(row: int, col: int, value: Variant)

var _resource: ClassTableResourceV2 = null
var _scroll: ScrollContainer
var _grid: GridContainer
var _header_row: HBoxContainer

## Row name column width
const ROW_NAME_WIDTH: int = 100
## Data column min width
const COLUMN_MIN_WIDTH: int = 120


func _ready() -> void:
	# Header row (separate from scroll so it stays visible)
	_header_row = HBoxContainer.new()
	_header_row.add_theme_constant_override("separation", 2)
	add_child(_header_row)

	var sep := HSeparator.new()
	add_child(sep)

	# Scrollable grid area
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(_scroll)

	_grid = GridContainer.new()
	_grid.size_flags_horizontal = SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 1)
	_scroll.add_child(_grid)


## Binds a table resource and builds the grid.
func set_resource(resource: ClassTableResourceV2) -> void:
	if _resource and _resource.data_changed.is_connected(_on_data_changed):
		_resource.data_changed.disconnect(_on_data_changed)

	_resource = resource

	if _resource:
		_resource.data_changed.connect(_on_data_changed)

	rebuild()


## Rebuilds the entire grid from the resource.
func rebuild() -> void:
	_clear_grid()

	if _resource == null or _resource.column_count == 0:
		return

	_build_headers()
	_build_rows()


# ── Header row ────────────────────────────────────────────────────────

func _build_headers() -> void:
	# Row name header
	var row_name_header := Button.new()
	row_name_header.text = "Row"
	row_name_header.flat = true
	row_name_header.disabled = true
	row_name_header.custom_minimum_size.x = ROW_NAME_WIDTH
	_header_row.add_child(row_name_header)

	# Column headers
	for col_idx: int in _resource.column_count:
		var meta: Dictionary = _resource.columns_metadata[col_idx]
		var btn := Button.new()
		btn.text = "%s (%s)" % [meta["name"], meta["type_name"]]
		btn.flat = true
		btn.disabled = true
		btn.size_flags_horizontal = SIZE_EXPAND_FILL
		btn.custom_minimum_size.x = COLUMN_MIN_WIDTH
		btn.tooltip_text = _column_tooltip(meta)
		_header_row.add_child(btn)

	# Set grid columns: row_name + data columns
	_grid.columns = 1 + _resource.column_count


# ── Data rows ─────────────────────────────────────────────────────────

func _build_rows() -> void:
	for row_idx: int in _resource.row_count:
		_add_row_controls(row_idx)


func _add_row_controls(row_idx: int) -> void:
	# Row name cell
	var name_edit := LineEdit.new()
	name_edit.text = _resource.row_names[row_idx] if row_idx < _resource.row_names.size() else ""
	name_edit.custom_minimum_size.x = ROW_NAME_WIDTH
	name_edit.placeholder_text = "row %d" % row_idx
	name_edit.text_submitted.connect(_on_row_name_changed.bind(row_idx))
	_grid.add_child(name_edit)

	# Data cells
	for col_idx: int in _resource.column_count:
		var meta: Dictionary = _resource.columns_metadata[col_idx]
		var value: Variant = _resource.get_cell(row_idx, col_idx)
		var ctrl: Control = _create_cell_editor(row_idx, col_idx, meta, value)
		ctrl.size_flags_horizontal = SIZE_EXPAND_FILL
		ctrl.custom_minimum_size.x = COLUMN_MIN_WIDTH
		_grid.add_child(ctrl)


# ── Cell editor factory ──────────────────────────────────────────────

func _create_cell_editor(row: int, col: int, meta: Dictionary, value: Variant) -> Control:
	var type: int = meta["type"]

	match type:
		TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
			return _make_string_editor(row, col, value)
		TYPE_INT:
			if meta.get("hint") == PROPERTY_HINT_ENUM:
				return _make_enum_editor(row, col, value, meta)
			return _make_int_editor(row, col, value)
		TYPE_FLOAT:
			return _make_float_editor(row, col, value)
		TYPE_BOOL:
			return _make_bool_editor(row, col, value)
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return _make_vector2_editor(row, col, value, type == TYPE_VECTOR2I)
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return _make_vector3_editor(row, col, value, type == TYPE_VECTOR3I)
		TYPE_VECTOR4, TYPE_VECTOR4I:
			return _make_vector4_editor(row, col, value, type == TYPE_VECTOR4I)
		TYPE_COLOR:
			return _make_color_editor(row, col, value)
		TYPE_RECT2, TYPE_RECT2I:
			return _make_rect2_editor(row, col, value, type == TYPE_RECT2I)
		TYPE_OBJECT:
			return _make_resource_editor(row, col, value, meta)

	# Fallback: label
	var lbl := Label.new()
	lbl.text = str(value) if value != null else ""
	return lbl


# ── Editor creators ───────────────────────────────────────────────────

func _make_string_editor(row: int, col: int, value: Variant) -> Control:
	var edit := LineEdit.new()
	edit.text = str(value) if value != null else ""
	edit.text_submitted.connect(func(t: String) -> void: _commit(row, col, t))
	edit.focus_exited.connect(func() -> void: _commit(row, col, edit.text))
	return edit


func _make_int_editor(row: int, col: int, value: Variant) -> Control:
	var slider := EditorSpinSlider.new()
	slider.min_value = -999999
	slider.max_value = 999999
	slider.step = 1
	slider.value = value if value is int or value is float else 0
	slider.editing_integer = true
	slider.value_changed.connect(func(v: float) -> void: _commit(row, col, int(v)))
	return slider


func _make_float_editor(row: int, col: int, value: Variant) -> Control:
	var slider := EditorSpinSlider.new()
	slider.min_value = -999999.0
	slider.max_value = 999999.0
	slider.step = 0.01
	slider.value = value if value is int or value is float else 0.0
	slider.value_changed.connect(func(v: float) -> void: _commit(row, col, v))
	return slider


func _make_bool_editor(row: int, col: int, value: Variant) -> Control:
	var check := CheckBox.new()
	check.button_pressed = value if value is bool else false
	check.toggled.connect(func(v: bool) -> void: _commit(row, col, v))
	return check


func _make_vector2_editor(row: int, col: int, value: Variant, is_int: bool) -> Control:
	var v: Variant = value if value is Vector2 or value is Vector2i else (Vector2i.ZERO if is_int else Vector2.ZERO)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	var sx := EditorSpinSlider.new()
	sx.label = "x"; sx.min_value = -999999; sx.max_value = 999999
	sx.step = 1 if is_int else 0.01; sx.value = v.x
	sx.editing_integer = is_int; sx.size_flags_horizontal = SIZE_EXPAND_FILL

	var sy := EditorSpinSlider.new()
	sy.label = "y"; sy.min_value = -999999; sy.max_value = 999999
	sy.step = 1 if is_int else 0.01; sy.value = v.y
	sy.editing_integer = is_int; sy.size_flags_horizontal = SIZE_EXPAND_FILL

	hbox.add_child(sx); hbox.add_child(sy)

	var commit_vec := func(_v: float) -> void:
		if is_int:
			_commit(row, col, Vector2i(int(sx.value), int(sy.value)))
		else:
			_commit(row, col, Vector2(sx.value, sy.value))
	sx.value_changed.connect(commit_vec)
	sy.value_changed.connect(commit_vec)
	return hbox


func _make_vector3_editor(row: int, col: int, value: Variant, is_int: bool) -> Control:
	var v: Variant = value if value is Vector3 or value is Vector3i else (Vector3i.ZERO if is_int else Vector3.ZERO)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	var sx := EditorSpinSlider.new()
	sx.label = "x"; sx.min_value = -999999; sx.max_value = 999999
	sx.step = 1 if is_int else 0.01; sx.value = v.x
	sx.editing_integer = is_int; sx.size_flags_horizontal = SIZE_EXPAND_FILL

	var sy := EditorSpinSlider.new()
	sy.label = "y"; sy.min_value = -999999; sy.max_value = 999999
	sy.step = 1 if is_int else 0.01; sy.value = v.y
	sy.editing_integer = is_int; sy.size_flags_horizontal = SIZE_EXPAND_FILL

	var sz := EditorSpinSlider.new()
	sz.label = "z"; sz.min_value = -999999; sz.max_value = 999999
	sz.step = 1 if is_int else 0.01; sz.value = v.z
	sz.editing_integer = is_int; sz.size_flags_horizontal = SIZE_EXPAND_FILL

	hbox.add_child(sx); hbox.add_child(sy); hbox.add_child(sz)

	var commit_vec := func(_v: float) -> void:
		if is_int:
			_commit(row, col, Vector3i(int(sx.value), int(sy.value), int(sz.value)))
		else:
			_commit(row, col, Vector3(sx.value, sy.value, sz.value))
	sx.value_changed.connect(commit_vec)
	sy.value_changed.connect(commit_vec)
	sz.value_changed.connect(commit_vec)
	return hbox


func _make_vector4_editor(row: int, col: int, value: Variant, is_int: bool) -> Control:
	var v: Variant = value if value is Vector4 or value is Vector4i else (Vector4i.ZERO if is_int else Vector4.ZERO)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	var sx := EditorSpinSlider.new()
	sx.label = "x"; sx.min_value = -999999; sx.max_value = 999999
	sx.step = 1 if is_int else 0.01; sx.value = v.x
	sx.editing_integer = is_int; sx.size_flags_horizontal = SIZE_EXPAND_FILL

	var sy := EditorSpinSlider.new()
	sy.label = "y"; sy.min_value = -999999; sy.max_value = 999999
	sy.step = 1 if is_int else 0.01; sy.value = v.y
	sy.editing_integer = is_int; sy.size_flags_horizontal = SIZE_EXPAND_FILL

	var sz := EditorSpinSlider.new()
	sz.label = "z"; sz.min_value = -999999; sz.max_value = 999999
	sz.step = 1 if is_int else 0.01; sz.value = v.z
	sz.editing_integer = is_int; sz.size_flags_horizontal = SIZE_EXPAND_FILL

	var sw := EditorSpinSlider.new()
	sw.label = "w"; sw.min_value = -999999; sw.max_value = 999999
	sw.step = 1 if is_int else 0.01; sw.value = v.w
	sw.editing_integer = is_int; sw.size_flags_horizontal = SIZE_EXPAND_FILL

	hbox.add_child(sx); hbox.add_child(sy); hbox.add_child(sz); hbox.add_child(sw)

	var commit_vec := func(_v: float) -> void:
		if is_int:
			_commit(row, col, Vector4i(int(sx.value), int(sy.value), int(sz.value), int(sw.value)))
		else:
			_commit(row, col, Vector4(sx.value, sy.value, sz.value, sw.value))
	sx.value_changed.connect(commit_vec)
	sy.value_changed.connect(commit_vec)
	sz.value_changed.connect(commit_vec)
	sw.value_changed.connect(commit_vec)
	return hbox


func _make_enum_editor(row: int, col: int, value: Variant, meta: Dictionary) -> Control:
	# hint_string format: "MELEE:0,RANGED:1" or "MELEE,RANGED"
	var hint_string: String = meta.get("hint_string", "")
	var options := OptionButton.new()
	var entries: PackedStringArray = hint_string.split(",")
	for entry: String in entries:
		var parts: PackedStringArray = entry.split(":")
		var label: String = parts[0].strip_edges()
		var id: int = parts[1].strip_edges().to_int() if parts.size() > 1 else options.item_count
		options.add_item(label, id)

	var current: int = value if value is int else 0
	# Select the item whose ID matches current value
	for i: int in options.item_count:
		if options.get_item_id(i) == current:
			options.selected = i
			break

	options.item_selected.connect(func(idx: int) -> void:
		_commit(row, col, options.get_item_id(idx))
	)
	return options


func _make_color_editor(row: int, col: int, value: Variant) -> Control:
	var picker := ColorPickerButton.new()
	picker.color = value if value is Color else Color.WHITE
	picker.edit_alpha = true
	picker.custom_minimum_size.y = 24
	picker.color_changed.connect(func(c: Color) -> void: _commit(row, col, c))
	return picker


func _make_rect2_editor(row: int, col: int, value: Variant, is_int: bool) -> Control:
	var v: Variant = value if value is Rect2 or value is Rect2i else (Rect2i() if is_int else Rect2())
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	var fields := ["x", "y", "w", "h"]
	var values := [v.position.x, v.position.y, v.size.x, v.size.y]
	var sliders: Array[EditorSpinSlider] = []

	for i: int in 4:
		var s := EditorSpinSlider.new()
		s.label = fields[i]; s.min_value = -999999; s.max_value = 999999
		s.step = 1 if is_int else 0.01; s.value = values[i]
		s.editing_integer = is_int; s.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(s)
		sliders.append(s)

	var commit_rect := func(_v: float) -> void:
		if is_int:
			_commit(row, col, Rect2i(
				int(sliders[0].value), int(sliders[1].value),
				int(sliders[2].value), int(sliders[3].value)))
		else:
			_commit(row, col, Rect2(
				sliders[0].value, sliders[1].value,
				sliders[2].value, sliders[3].value))

	for s: EditorSpinSlider in sliders:
		s.value_changed.connect(commit_rect)
	return hbox


func _make_resource_editor(row: int, col: int, value: Variant, meta: Dictionary) -> Control:
	var hint_string: String = meta.get("hint_string", "")
	# hint_string for Object types often contains the class name (e.g. "PackedScene", "Texture2D")
	var base_type: String = hint_string if not hint_string.is_empty() else "Resource"

	var picker := EditorResourcePicker.new()
	picker.base_type = base_type
	if value is Resource:
		picker.edited_resource = value
	picker.resource_changed.connect(func(res: Resource) -> void: _commit(row, col, res))
	return picker


# ── Internals ─────────────────────────────────────────────────────────

func _commit(row: int, col: int, value: Variant) -> void:
	if _resource:
		_resource.set_cell(row, col, value)
	cell_edited.emit(row, col, value)


func _on_row_name_changed(new_name: String, row_idx: int) -> void:
	if _resource and row_idx < _resource.row_names.size():
		_resource.row_names[row_idx] = new_name


func _on_data_changed() -> void:
	# For now, don't auto-rebuild — only rebuild on explicit set_resource() or rebuild()
	pass


func _clear_grid() -> void:
	# Clear headers
	for child: Node in _header_row.get_children():
		child.queue_free()
	# Clear grid cells
	for child: Node in _grid.get_children():
		child.queue_free()


func _column_tooltip(meta: Dictionary) -> String:
	var parts: PackedStringArray = [
		"Type: %s" % meta.get("type_name", "?"),
	]
	var hint_str: String = meta.get("hint_string", "")
	if not hint_str.is_empty():
		parts.append("Hint: %s" % hint_str)
	var default_val: Variant = meta.get("default")
	if default_val != null:
		parts.append("Default: %s" % str(default_val))
	return "\n".join(parts)
