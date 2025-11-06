@tool
extends FileDialog

## CSV Export Dialog for Class Table Editor
## Simple file dialog for exporting class tables to CSV with type hints

signal export_confirmed(file_path: String)


func _ready() -> void:
	_setup_dialog()
	_connect_signals()


func _setup_dialog() -> void:
	"""Configure dialog properties for CSV export"""
	title = "Export Class Table to CSV"
	file_mode = FileDialog.FILE_MODE_SAVE_FILE
	access = FileDialog.ACCESS_RESOURCES
	filters = PackedStringArray(["*.csv ; CSV Files"])
	current_dir = "res://"
	current_file = "export.csv"


func _connect_signals() -> void:
	"""Connect dialog signals"""
	file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	"""Handle file selection"""
	# Ensure .csv extension
	if not path.ends_with(".csv"):
		path += ".csv"

	export_confirmed.emit(path)


func show_dialog() -> void:
	"""Show the export dialog"""
	popup_centered_ratio(0.6)
