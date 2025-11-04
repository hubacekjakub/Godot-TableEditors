@tool
extends VBoxContainer

## Resource Collection Editor Dock UI Controller - Plugin 3: Bulk Resource Editor

signal collection_changed
signal resource_added
signal resource_removed
signal save_requested
signal load_collection_requested
signal close_requested
signal new_collection_requested
signal collection_selected(path: String)

# UI References (automatically connected from scene)
@onready var file_menu: MenuButton = %FileMenu
@onready var tools_menu: MenuButton = %ToolsMenu
@onready var add_resource_btn: Button = %AddResourceBtn
@onready var remove_resource_btn: Button = %RemoveResourceBtn
@onready var collection_info_label: Label = %CollectionInfoLabel
@onready var resources_count_label: Label = %ResourcesCountLabel
@onready var recent_collections_list: ItemList = %RecentCollectionsList
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var resources_table: GridContainer = %ResourcesTable

var current_collection: Resource = null
var recent_collections: Array[String] = []
const MAX_RECENT_COLLECTIONS = 10


func _ready() -> void:
	_setup_menus()
	_connect_signals()
	_update_recent_collections_list()


func _setup_menus() -> void:
	# Setup File menu
	var file_popup := file_menu.get_popup()
	file_popup.clear()
	file_popup.add_item("New Collection", 0)
	file_popup.add_item("Load Collection", 1)
	file_popup.add_item("Save", 2)
	file_popup.add_separator()
	file_popup.add_item("Close", 3)
	file_popup.id_pressed.connect(_on_file_menu_pressed)

	# Setup Tools menu
	var tools_popup := tools_menu.get_popup()
	tools_popup.clear()
	tools_popup.add_item("Scan Folder for Resources", 0)
	tools_popup.add_item("Refresh Collection", 1)
	tools_popup.add_separator()
	tools_popup.add_item("Clear Collection", 2)
	tools_popup.id_pressed.connect(_on_tools_menu_pressed)


func _connect_signals() -> void:
	add_resource_btn.pressed.connect(_on_add_resource_pressed)
	remove_resource_btn.pressed.connect(_on_remove_resource_pressed)
	recent_collections_list.item_selected.connect(_on_recent_collection_selected)


func set_collection(collection: Resource) -> void:
	"""Set the current collection and update the UI"""
	current_collection = collection
	update_ui()


func update_ui() -> void:
	"""Update the UI to reflect the current collection data"""
	if not current_collection or not current_collection is ResourceCollection:
		collection_info_label.text = "No collection loaded"
		resources_count_label.text = "Resources: 0"
		_rebuild_resources_table.call_deferred()
		_update_recent_collections_list()
		return

	var collection := current_collection as ResourceCollection
	collection_info_label.text = "Collection: %s" % collection.collection_name
	resources_count_label.text = "Resources: %d" % collection.get_resource_count()
	_rebuild_resources_table.call_deferred()
	_update_recent_collections_list()


func _rebuild_resources_table() -> void:
	"""Rebuild the entire resources table based on current collection data"""
	# Clear existing table
	for child in resources_table.get_children():
		child.queue_free()

	if not current_collection or not current_collection is ResourceCollection:
		var label := Label.new()
		label.text = "No collection loaded"
		resources_table.add_child(label)
		return

	var collection := current_collection as ResourceCollection

	# Set table columns
	resources_table.columns = 2  # Filename and Path

	# Add column headers
	var filename_header := Label.new()
	filename_header.text = "File Name"
	filename_header.add_theme_stylebox_override("normal", _get_header_style())
	filename_header.custom_minimum_size = Vector2(200, 30)
	resources_table.add_child(filename_header)

	var path_header := Label.new()
	path_header.text = "Path"
	path_header.add_theme_stylebox_override("normal", _get_header_style())
	path_header.custom_minimum_size = Vector2(400, 30)
	resources_table.add_child(path_header)

	# Add resource rows
	var resources := collection.get_all_resources()
	if resources.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No resources in collection"
		resources_table.add_child(empty_label)
		return

	for resource_path in resources:
		var file_name := resource_path.get_file()

		# Filename label
		var filename_label := Label.new()
		filename_label.text = file_name
		filename_label.custom_minimum_size = Vector2(200, 30)
		resources_table.add_child(filename_label)

		# Path label
		var path_label := Label.new()
		path_label.text = resource_path
		path_label.clip_text = true
		path_label.custom_minimum_size = Vector2(400, 30)
		resources_table.add_child(path_label)


func _get_header_style() -> StyleBoxFlat:
	"""Create and return header style"""
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.22, 0.22, 0.22, 1)
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.4, 1)
	return style


func _on_file_menu_pressed(id: int) -> void:
	match id:
		0:  # New Collection
			new_collection_requested.emit()
		1:  # Load Collection
			load_collection_requested.emit()
		2:  # Save
			save_requested.emit()
		3:  # Close
			close_requested.emit()


func _on_tools_menu_pressed(id: int) -> void:
	match id:
		0:  # Scan Folder for Resources
			_on_scan_folder_pressed()
		1:  # Refresh Collection
			update_ui.call_deferred()
		2:  # Clear Collection
			_on_clear_collection_pressed()


func _on_add_resource_pressed() -> void:
	"""Show dialog to add a resource to the collection"""
	if not current_collection or not current_collection is ResourceCollection:
		push_warning("No collection loaded to add resources to")
		return
	resource_added.emit()


func _on_remove_resource_pressed() -> void:
	"""Remove selected resource from collection"""
	if not current_collection or not current_collection is ResourceCollection:
		return
	resource_removed.emit()


func _on_scan_folder_pressed() -> void:
	"""Show dialog to scan folder for resources"""
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.current_dir = "res://"
	dialog.title = "Select Folder to Scan"
	dialog.dir_selected.connect(_on_folder_selected_for_scan)

	get_tree().root.add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_folder_selected_for_scan(folder_path: String) -> void:
	"""Scan selected folder for resource files"""
	if not current_collection or not current_collection is ResourceCollection:
		return

	var collection := current_collection as ResourceCollection
	collection.resource_folder_path = folder_path

	# Scan folder for .tres files
	var dir := DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") and not file_name.ends_with(".import"):
				var full_path := folder_path + "/" + file_name
				collection.add_resource(full_path)
			file_name = dir.get_next()

	print("Scanned folder: " + folder_path + " - found " + str(collection.get_resource_count()) + " resources")
	update_ui.call_deferred()


func _on_clear_collection_pressed() -> void:
	"""Clear all resources from the collection"""
	if not current_collection or not current_collection is ResourceCollection:
		return

	var collection := current_collection as ResourceCollection
	collection.clear_collection()
	update_ui.call_deferred()


func add_to_recent_collections(path: String) -> void:
	"""Add a collection path to the recent collections list"""
	if path.is_empty():
		return

	# Don't add if already exists (keep original order)
	if path in recent_collections:
		return

	# Add to end of list
	recent_collections.append(path)

	# Limit to MAX_RECENT_COLLECTIONS
	if recent_collections.size() > MAX_RECENT_COLLECTIONS:
		recent_collections.pop_front()

	_update_recent_collections_list()


func _update_recent_collections_list() -> void:
	"""Update the ItemList display with recent collections"""
	recent_collections_list.clear()

	for i in range(recent_collections.size()):
		var path := recent_collections[i]
		var file_name := path.get_file()
		recent_collections_list.add_item(file_name)
		recent_collections_list.set_item_tooltip(i, path)

		# Highlight the currently active collection
		if current_collection and current_collection.resource_path == path:
			recent_collections_list.set_item_custom_bg_color(i, Color(0.3, 0.5, 0.7, 0.3))
			recent_collections_list.set_item_custom_fg_color(i, Color(1, 1, 1, 1))


func _on_recent_collection_selected(index: int) -> void:
	"""Handle selection of a recent collection from the list"""
	if index >= 0 and index < recent_collections.size():
		var path := recent_collections[index]
		collection_selected.emit(path)
