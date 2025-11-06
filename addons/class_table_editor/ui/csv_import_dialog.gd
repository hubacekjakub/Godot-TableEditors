@tool
extends FileDialog

## CSV Import Dialog for Class Table Editor
## Simple file dialog for importing CSV files into class tables

signal import_confirmed(file_path: String)


func _ready() -> void:
	_setup_dialog()
	_connect_signals()


func _setup_dialog() -> void:
	"""Configure dialog properties for CSV import"""
	title = "Import CSV into Class Table"
	file_mode = FileDialog.FILE_MODE_OPEN_FILE
	access = FileDialog.ACCESS_RESOURCES
	filters = PackedStringArray(["*.csv ; CSV Files"])
	current_dir = "res://"


func _connect_signals() -> void:
	"""Connect dialog signals"""
	file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	"""Handle file selection"""
	import_confirmed.emit(path)


func show_dialog() -> void:
	"""Show the import dialog"""
	popup_centered_ratio(0.6)
