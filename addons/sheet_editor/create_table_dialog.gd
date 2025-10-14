@tool
extends ConfirmationDialog

## Create Table Dialog Controller
## Handles UI for creating new data tables

signal table_creation_confirmed(table_name: String, rows: int, columns: int, save_path: String)

@onready var name_edit: LineEdit = %NameEdit
@onready var rows_spinbox: SpinBox = %RowsSpinBox
@onready var columns_spinbox: SpinBox = %ColumnsSpinBox
@onready var path_edit: LineEdit = %PathEdit
@onready var browse_button: Button = %BrowseButton

var file_dialog: EditorFileDialog = null


func _ready() -> void:
	_setup_dialog()
	_connect_signals()


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


func _connect_signals() -> void:
	"""Connect UI signals"""
	browse_button.pressed.connect(_on_browse_pressed)

	# Validate inputs on text change
	name_edit.text_changed.connect(_validate_inputs)
	path_edit.text_changed.connect(_validate_inputs)


func _validate_inputs(_text: String = "") -> void:
	"""Validate user inputs and enable/disable OK button"""
	var is_valid := true

	# Check table name
	if name_edit.text.strip_edges().is_empty():
		is_valid = false

	# Check path
	if path_edit.text.strip_edges().is_empty():
		is_valid = false

	get_ok_button().disabled = not is_valid


func _on_browse_pressed() -> void:
	"""Show directory picker dialog"""
	if file_dialog:
		# Set initial directory from path_edit if valid
		var current_path := path_edit.text.strip_edges()
		if current_path.begins_with("res://"):
			file_dialog.current_dir = current_path
		file_dialog.popup_centered_ratio(0.6)


func _on_directory_selected(dir: String) -> void:
	"""Handle directory selection from file dialog"""
	# Ensure path ends with slash
	if not dir.ends_with("/"):
		dir += "/"
	path_edit.text = dir


func _on_confirmed() -> void:
	"""Handle dialog confirmation"""
	var table_name := name_edit.text.strip_edges()
	var num_rows := int(rows_spinbox.value)
	var num_columns := int(columns_spinbox.value)
	var save_path := path_edit.text.strip_edges()

	# Validate and clean inputs
	if table_name.is_empty():
		table_name = "MyTable"

	if not save_path.ends_with("/"):
		save_path += "/"

	# Emit signal with validated parameters
	table_creation_confirmed.emit(table_name, num_rows, num_columns, save_path)


func reset_to_defaults() -> void:
	"""Reset all fields to default values"""
	name_edit.text = "MyTable"
	rows_spinbox.value = 10
	columns_spinbox.value = 5
	path_edit.text = "res://resources/"
	_validate_inputs()
