@tool
extends EditorProperty

## Custom editor for TableHandle resources
## Provides a table resource picker and a row name selector

var table_picker: EditorResourcePicker
var row_selector: OptionButton
var container: VBoxContainer
var current_handle: TableHandle = null
var updating: bool = false


func _init():
	# Create vertical container for two-line layout
	container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(container)

	# First row: Labels
	var labels = HBoxContainer.new()
	container.add_child(labels)

	var table_label = Label.new()
	table_label.text = "Table"
	table_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.add_child(table_label)

	var row_label = Label.new()
	row_label.text = "Row"
	row_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.add_child(row_label)

	# Second row: Controls
	var controls = HBoxContainer.new()
	container.add_child(controls)

	# Table resource picker
	table_picker = EditorResourcePicker.new()
	table_picker.base_type = "ClassTableResource"
	table_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table_picker.resource_changed.connect(_on_table_changed)
	controls.add_child(table_picker)

	# Row selector dropdown
	row_selector = OptionButton.new()
	row_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_selector.item_selected.connect(_on_row_selected)
	controls.add_child(row_selector)

	# Make the property take up full width
	set_bottom_editor(container)


## Called when the property value changes externally.
func _update_property():
	if updating:
		return

	updating = true

	# Get the current TableHandle value
	var new_handle = get_edited_object()[get_edited_property()]

	if new_handle == null:
		# Create a new empty handle if none exists
		new_handle = TableHandle.new()
		get_edited_object()[get_edited_property()] = new_handle

	current_handle = new_handle

	# Update table picker
	table_picker.edited_resource = current_handle.table_resource

	# Update row selector
	_refresh_row_list()

	updating = false


## Called when table resource is changed in the picker.
func _on_table_changed(resource: Resource):
	if updating:
		return

	if not current_handle:
		current_handle = TableHandle.new()

	updating = true

	# Update the table resource
	current_handle.table_resource = resource as ClassTableResource

	# Clear row selection when table changes
	current_handle.row_name = ""

	# Refresh row list
	_refresh_row_list()

	# Emit change signal
	emit_changed(get_edited_property(), current_handle)

	updating = false


## Called when a row is selected from the dropdown.
func _on_row_selected(index: int):
	if updating or index < 0:
		return

	if not current_handle:
		current_handle = TableHandle.new()

	updating = true

	# Get the selected row name
	var selected_name = row_selector.get_item_text(index)
	current_handle.row_name = selected_name

	# Emit change signal
	emit_changed(get_edited_property(), current_handle)

	updating = false


## Refresh the row selector with current table rows.
func _refresh_row_list():
	row_selector.clear()

	if not current_handle or not current_handle.table_resource:
		row_selector.disabled = true
		return

	row_selector.disabled = false

	var table = current_handle.table_resource
	var selected_index = -1

	# Populate with row names from first column (name column)
	for row in range(table.row_count):
		var row_name = table.get_cell(row, 0)  # First column should be "name"
		if row_name.is_empty():
			row_name = "(empty)"

		row_selector.add_item(row_name)

		# Check if this is the currently selected row
		if row_name == current_handle.row_name:
			selected_index = row

	# Set the selected item
	if selected_index >= 0:
		row_selector.selected = selected_index
	elif row_selector.item_count > 0:
		row_selector.selected = 0

