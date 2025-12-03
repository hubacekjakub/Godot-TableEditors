@tool
extends PanelContainer
## A simple panel to demonstrate that editor plugins use regular Godot UI.
##
## This script is attached to a .tscn scene - the same workflow you use for game UI!

var click_count: int = 0
var spawned_buttons: Array[Button] = []

# All the places we can spawn buttons! 🎉
const LOCATIONS := [
	# --- TOOLBAR & MENUS ---
	{"type": "container", "slot": EditorPlugin.CONTAINER_TOOLBAR, "name": "Main Toolbar"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, "name": "3D Viewport Menu"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, "name": "2D Viewport Menu"},

	# --- 3D VIEWPORT SIDES ---
	{"type": "container", "slot": EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, "name": "3D Left Sidebar"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT, "name": "3D Right Sidebar"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_SPATIAL_EDITOR_BOTTOM, "name": "3D Bottom Bar"},

	# --- 2D VIEWPORT SIDES ---
	{"type": "container", "slot": EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, "name": "2D Menu"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT, "name": "2D Left Sidebar"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, "name": "2D Right Sidebar"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, "name": "2D Bottom Bar"},

	# --- LEFT DOCKS (Scene Tree area) ---
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_LEFT_UL, "name": "Left Dock Upper-Left"},
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_LEFT_UR, "name": "Left Dock Upper-Right"},
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_LEFT_BL, "name": "Left Dock Bottom-Left"},
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_LEFT_BR, "name": "Left Dock Bottom-Right"},

	# --- RIGHT DOCKS (Inspector area) ---
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_RIGHT_UL, "name": "Right Dock Upper-Left"},
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_RIGHT_UR, "name": "Right Dock Upper-Right"},
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_RIGHT_BL, "name": "Right Dock Bottom-Left"},
	{"type": "dock", "slot": EditorPlugin.DOCK_SLOT_RIGHT_BR, "name": "Right Dock Bottom-Right"},

	# --- INSPECTOR ---
	{"type": "container", "slot": EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, "name": "Inspector Bottom"},

	# --- PROJECT SETTINGS (open Project Settings to see these!) ---
	{"type": "container", "slot": EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_LEFT, "name": "Project Settings Left"},
	{"type": "container", "slot": EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, "name": "Project Settings Right"},
]

@onready var bazinga_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BazingaButton
@onready var count_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CountLabel

func _ready() -> void:
	# Connect the button - exactly like you would in a game!
	bazinga_button.pressed.connect(_on_bazinga_pressed)


func _on_bazinga_pressed() -> void:
	click_count += 1
	count_label.text = "  Clicks: %d" % click_count

	# Get the editor plugin to spawn buttons
	var plugin := _get_editor_plugin()
	if not plugin:
		print("🎉 BAZINGA #%d! (Can't spawn - no plugin reference)" % click_count)
		return

	# Spawn a button at a new location!
	if click_count <= LOCATIONS.size():
		var loc = LOCATIONS[click_count - 1]
		var new_button := Button.new()
		new_button.text = "🎉 Bazinga #%d!" % click_count
		new_button.pressed.connect(_on_spawned_button_pressed.bind(click_count))

		if loc.type == "container":
			plugin.add_control_to_container(loc.slot, new_button)
		else:
			plugin.add_control_to_dock(loc.slot, new_button)

		spawned_buttons.append(new_button)
		print("🎉 BAZINGA #%d spawned in: %s!" % [click_count, loc.name])
		print("   → The editor is filling up with Bazingas...")
	else:
		print("🎉 BAZINGA #%d! You've conquered the entire editor!" % click_count)
		print("   → There's nowhere left to put buttons! 😄")

	# Fun messages
	match click_count:
		1:
			print("   → Same nodes, same signals, same workflow as game UI.")
		2:
			print("   → Look! Buttons are appearing everywhere!")
		3:
			print("   → You already know how to build editor plugins!")
		5:
			print("   → The 3D viewport is getting crowded...")
		10:
			print("   → 2D viewport too! Bazingas everywhere!")
		15:
			print("   → All the docks are filling up!")
		20:
			print("   → Even Project Settings isn't safe!")
		22:  # LOCATIONS.size() - when all locations are filled
			print("   → 🏆 ACHIEVEMENT UNLOCKED: Total Editor Domination!")


func _on_spawned_button_pressed(which: int) -> void:
	print("🎉 You clicked Bazinga #%d!" % which)


func _get_editor_plugin() -> EditorPlugin:
	# The plugin stores itself as meta when it creates us
	if has_meta("editor_plugin"):
		return get_meta("editor_plugin") as EditorPlugin
	return null


func cleanup_spawned_buttons(plugin: EditorPlugin) -> void:
	# Called by plugin.gd on exit
	for i in range(spawned_buttons.size()):
		var btn = spawned_buttons[i]
		if is_instance_valid(btn):
			var loc = LOCATIONS[i]
			if loc.type == "container":
				plugin.remove_control_from_container(loc.slot, btn)
			else:
				plugin.remove_control_from_docks(btn)
			btn.queue_free()
	spawned_buttons.clear()
