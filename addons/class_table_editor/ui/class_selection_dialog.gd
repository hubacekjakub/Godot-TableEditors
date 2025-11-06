@tool
extends ConfirmationDialog

signal class_selected(class_info: Dictionary)
signal table_created(resource_path: String, class_info: Dictionary)

@onready var class_list: ItemList = %ClassList
@onready var class_name_label: Label = %ClassNameLabel
@onready var properties_count_label: Label = %PropertiesCountLabel
@onready var properties_list: ItemList = %PropertiesList
@onready var name_edit: LineEdit = %NameEdit
@onready var path_edit: LineEdit = %PathEdit
@onready var browse_button: Button = %BrowseButton
@onready var refresh_button: Button = %RefreshButton
@onready var warning_text: Label = %WarningText

var file_dialog: EditorFileDialog = null
var class_selector: ClassSelector = null
var selected_class_info: Dictionary = {}


func _ready() -> void:
	_setup_dialog()
	_connect_signals()
	_load_classes()


func _setup_dialog() -> void:
	## Setup dialog properties.
	confirmed.connect(_on_confirmed)

	# Create EditorFileDialog for browsing directories
	file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.current_dir = "res://"
	file_dialog.title = "Select Save Directory"
	file_dialog.dir_selected.connect(_on_directory_selected)
	add_child(file_dialog)

	# Initialize ClassSelector
	class_selector = ClassSelector.new()


func _connect_signals() -> void:
	## Connect UI signals.
	class_list.item_selected.connect(_on_class_selected)
	browse_button.pressed.connect(_on_browse_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)

	# Validate inputs when they change
	name_edit.text_changed.connect(_on_input_changed)
	path_edit.text_changed.connect(_on_input_changed)


func _load_classes() -> void:
	## Discover and load all available classes in project.
	if class_selector == null:
		return

	class_list.clear()

	var classes: Array = class_selector.get_all_classes(true)  # Force rescan

	for class_info in classes:
		var cls_name: String = class_info.get("class_name", "Unknown")
		var prop_count: int = class_info.get("property_count", 0)
		var display_text: String = "%s (%d properties)" % [cls_name, prop_count]

		if class_info.get("property_count", 0) == 0:
			continue  # Skip classes with no properties

		class_list.add_item(display_text)

		# Store the class info in the item's metadata
		class_list.set_item_metadata(class_list.item_count - 1, class_info)


func _on_class_selected(index: int) -> void:
	## Handle class selection from list.
	if index < 0 or index >= class_list.item_count:
		return

	selected_class_info = class_list.get_item_metadata(index)
	_update_properties_display()
	_validate_inputs()


func _update_properties_display() -> void:
	## Update the table name based on selected class.
	if selected_class_info.is_empty():
		name_edit.text = ""
		class_name_label.text = "Class: (none selected)"
		properties_count_label.text = "Properties: 0"
		properties_list.clear()
		return

	var cls_name: String = selected_class_info.get("class_name", "Unknown")
	var file_path: String = selected_class_info.get("file_path", "")
	var parent: String = selected_class_info.get("parent_class", "")
	var properties: Array = selected_class_info.get("properties", [])

	# Update class name label
	var class_text: String = "Class: %s" % cls_name
	if not parent.is_empty():
		class_text += " (extends %s)" % parent
	class_name_label.text = class_text

	# Update properties count
	properties_count_label.text = "Properties: %d" % properties.size()

	# Populate properties list
	properties_list.clear()
	for prop in properties:
		var prop_name: String = prop.get("name", "?")
		var prop_type: String = prop.get("type_name", "?")
		var item_text: String = "%s: %s" % [prop_type, prop_name]
		properties_list.add_item(item_text)

	# Auto-generate table name from class name
	name_edit.text = cls_name + "Table"

	_validate_inputs()


func _on_input_changed(_text: String = "") -> void:
	## Validate inputs whenever they change.
	_validate_inputs()


func _validate_inputs() -> void:
	## Validate user inputs and enable/disable OK button.
	var is_valid: bool = true

	# Must have a class selected
	if selected_class_info.is_empty():
		is_valid = false

	# Table name required
	if name_edit.text.strip_edges().is_empty():
		is_valid = false

	# Path required
	if path_edit.text.strip_edges().is_empty():
		is_valid = false

	# Check for file collision
	var has_collision: bool = _check_file_collision()
	if has_collision:
		is_valid = false

	get_ok_button().disabled = not is_valid


func _check_file_collision() -> bool:
	## Check if a file with the same name already exists and show warning.
	## Returns true if collision detected.
	var table_name: String = name_edit.text.strip_edges()
	var save_path: String = path_edit.text.strip_edges()

	if table_name.is_empty() or save_path.is_empty():
		warning_text.visible = false
		return false

	# Ensure path ends with slash
	if not save_path.ends_with("/"):
		save_path += "/"

	# Generate filename from table name
	var file_name: String = table_name + ".tres"
	var full_path: String = save_path + file_name

	# Check if file exists
	if FileAccess.file_exists(full_path):
		warning_text.text = "⚠️ WARNING: File '%s' already exists!" % file_name
		warning_text.visible = true
		return true
	else:
		warning_text.visible = false
		return false


func _on_browse_pressed() -> void:
	## Show directory picker dialog.
	if file_dialog:
		var current_path: String = path_edit.text.strip_edges()
		if current_path.begins_with("res://"):
			file_dialog.current_dir = current_path
		file_dialog.popup_centered_ratio(0.6)


func _on_directory_selected(dir: String) -> void:
	## Handle directory selection from file dialog.
	if not dir.ends_with("/"):
		dir += "/"
	path_edit.text = dir


func _on_refresh_pressed() -> void:
	## Refresh the class list from disk.
	_load_classes()


func _on_confirmed() -> void:
	## Handle dialog confirmation and create table from selected class.
	if selected_class_info.is_empty():
		push_error("No class selected")
		return

	var table_name: String = name_edit.text.strip_edges()
	var save_path: String = path_edit.text.strip_edges()
	var class_file_path: String = selected_class_info.get("file_path", "")
	var cls_name: String = selected_class_info.get("class_name", "Unknown")

	# Ensure path ends with slash
	if not save_path.ends_with("/"):
		save_path += "/"

	# Generate filename from table name instead of class name
	var file_name: String = table_name + ".tres"
	var full_path: String = save_path + file_name

	# Create new ClassTableResource
	var table_resource: ClassTableResource = ClassTableResource.new()
	table_resource.sheet_name = table_name
	table_resource.source_class_name = cls_name
	table_resource.class_file_path = class_file_path

	# Add "name" column as first column
	table_resource.add_column_with_type("name", "String", "", true)

	# Auto-generate table columns from class properties
	if not table_resource.create_columns_from_class(class_file_path):
		push_error("Failed to create columns from class: " + class_file_path)
		return

	# Create new class table instances with initial rows
	table_resource.row_count = 0
	table_resource.column_count = table_resource.columns_metadata.size()

	# Add 3 default rows
	for i in range(3):
		table_resource.add_row(str(i + 1))

	# Save the resource
	var error: int = ResourceSaver.save(table_resource, full_path)
	if error != OK:
		push_error("Failed to save table resource: " + full_path)
		return

	print("Created table from class: %s" % cls_name)
	print("  - Columns: %d" % table_resource.column_count)
	print("  - Saved to: %s" % full_path)

	# Emit signals
	class_selected.emit(selected_class_info)
	table_created.emit(full_path, selected_class_info)


func reset_to_defaults() -> void:
	## Reset dialog to default state.
	if not is_node_ready():
		call_deferred("reset_to_defaults")
		return

	class_list.deselect_all()
	selected_class_info = {}
	name_edit.text = ""
	path_edit.text = "res://resources/"
	warning_text.visible = false
	_validate_inputs()


## Clean up when dialog is exiting the tree.
func _exit_tree() -> void:
	if file_dialog:
		file_dialog.queue_free()
