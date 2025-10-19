@tool
extends ConfirmationDialog

signal class_selected(class_info: Dictionary)
signal table_created(resource_path: String, class_info: Dictionary)

@onready var class_list: ItemList = %ClassList
@onready var name_edit: LineEdit = %NameEdit
@onready var path_edit: LineEdit = %PathEdit
@onready var browse_button: Button = %BrowseButton
@onready var refresh_button: Button = %RefreshButton

var file_dialog: EditorFileDialog = null
var class_selector: ClassSelector = null
var selected_class_info: Dictionary = {}


func _ready() -> void:
	_setup_dialog()
	_connect_signals()
	_load_classes()


func _setup_dialog() -> void:
	"""Setup dialog properties"""
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
	"""Connect UI signals"""
	class_list.item_selected.connect(_on_class_selected)
	browse_button.pressed.connect(_on_browse_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)

	# Validate inputs when they change
	name_edit.text_changed.connect(_on_input_changed)
	path_edit.text_changed.connect(_on_input_changed)


func _load_classes() -> void:
	"""Discover and load all available classes in project"""
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
	"""Handle class selection from list"""
	if index < 0 or index >= class_list.item_count:
		return

	selected_class_info = class_list.get_item_metadata(index)
	_update_properties_display()
	_validate_inputs()


func _update_properties_display() -> void:
	"""Update the table name based on selected class"""
	if selected_class_info.is_empty():
		name_edit.text = ""
		return

	var cls_name: String = selected_class_info.get("class_name", "Unknown")

	# Auto-generate table name from class name
	name_edit.text = cls_name + "Table"

	_validate_inputs()


func _on_input_changed(_text: String = "") -> void:
	"""Validate inputs whenever they change"""
	_validate_inputs()


func _validate_inputs() -> void:
	"""Validate user inputs and enable/disable OK button"""
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

	get_ok_button().disabled = not is_valid


func _on_browse_pressed() -> void:
	"""Show directory picker dialog"""
	if file_dialog:
		var current_path: String = path_edit.text.strip_edges()
		if current_path.begins_with("res://"):
			file_dialog.current_dir = current_path
		file_dialog.popup_centered_ratio(0.6)


func _on_directory_selected(dir: String) -> void:
	"""Handle directory selection from file dialog"""
	if not dir.ends_with("/"):
		dir += "/"
	path_edit.text = dir


func _on_refresh_pressed() -> void:
	"""Refresh the class list from disk"""
	_load_classes()


func _on_confirmed() -> void:
	"""Handle dialog confirmation - create table from selected class"""
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

	# Generate filename from class name
	var file_name: String = cls_name.to_lower() + "_table.tres"
	var full_path: String = save_path + file_name

	# Create new ClassTableResource
	var table_resource: ClassTableResource = ClassTableResource.new()
	table_resource.sheet_name = table_name
	table_resource.source_class_name = cls_name
	table_resource.class_file_path = class_file_path

	# P2-012: Auto-generate table columns from class properties
	if not table_resource.create_columns_from_class(class_file_path):
		push_error("Failed to create columns from class: " + class_file_path)
		return

	# P2-017: Create new class table instances with initial rows
	table_resource.row_count = 0
	table_resource.column_count = table_resource.columns_metadata.size()

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
	"""Reset dialog to default state"""
	if not is_node_ready():
		call_deferred("reset_to_defaults")
		return

	class_list.deselect_all()
	selected_class_info = {}
	name_edit.text = ""
	path_edit.text = "res://resources/"
	_validate_inputs()
