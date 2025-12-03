# Presentation Code Snippets

Code snippets for the "Godot Plugins - The Editor's Secret Weapon" presentation.

**Plugin Location:** `addons/bazinga/` (pre-built and ready to use!)

---

## Section 7: Live Demo - The "Bazinga!" Plugin

### File: `addons/bazinga/plugin.cfg`

```ini
[plugin]

name="Bazinga!"
description="The simplest plugin that proves you can extend anything."
author="Jakub Hubáček"
version="1.0"
script="plugin.gd"
```

---

### File: `addons/bazinga/plugin.gd`

```gdscript
@tool
extends EditorPlugin

# ============================================================
# DEMO MODE: Toggle between "simple button" and "scene-based UI"
# Set to true to show how .tscn scenes work as editor plugins!
# ============================================================
const USE_SCENE_UI := true

var button: Button
var panel: Control


func _enter_tree():
	if USE_SCENE_UI:
		# ============================================================
		# SCENE-BASED UI - The real power!
		# This loads a regular .tscn scene, just like game UI.
		# Same nodes, same signals, same workflow you already know.
		# ============================================================
		panel = preload("res://addons/bazinga/bazinga_panel.tscn").instantiate()
		add_control_to_bottom_panel(panel, "🎉 Bazinga!")
		print("Bazinga Panel loaded! Check the bottom tabs.")
	else:
		# ============================================================
		# SIMPLE BUTTON MODE - For showing different locations
		# Uncomment ONE line at a time to show different positions.
		# ============================================================
		button = Button.new()
		button.text = "🎉 Bazinga!"
		button.pressed.connect(_on_bazinga_pressed)

		# --- TOP OF THE EDITOR ---
		add_control_to_container(CONTAINER_TOOLBAR, button)
		#add_control_to_dock(DOCK_SLOT_RIGHT_UL, button)
		#add_control_to_bottom_panel(button, "Bazinga!")


func _exit_tree():
	if USE_SCENE_UI:
		if panel:
			remove_control_from_bottom_panel(panel)
			panel.queue_free()
	else:
		if button:
			remove_control_from_container(CONTAINER_TOOLBAR, button)
			button.queue_free()


func _on_bazinga_pressed():
	print("🎉 BAZINGA! You just extended the Godot Editor!")
```

---

### File: `addons/bazinga/bazinga_panel.tscn` (Scene-based UI)

A regular Godot scene with:
- `PanelContainer` (root)
  - `MarginContainer`
    - `VBoxContainer`
      - `Label` - Title
      - `Label` - Description
      - `HSeparator`
      - `HBoxContainer`
        - `Button` - "🎉 BAZINGA!"
        - `Label` - Click counter

---

### File: `addons/bazinga/bazinga_panel.gd` (Scene script)

```gdscript
@tool
extends PanelContainer
## A simple panel to demonstrate that editor plugins use regular Godot UI.

var click_count: int = 0

@onready var bazinga_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BazingaButton
@onready var count_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CountLabel


func _ready() -> void:
	bazinga_button.pressed.connect(_on_bazinga_pressed)


func _on_bazinga_pressed() -> void:
	click_count += 1
	count_label.text = "  Clicks: %d" % click_count
	print("🎉 BAZINGA #%d! This UI is just a regular Godot scene." % click_count)

	match click_count:
		1: print("   → Same nodes, same signals, same workflow as game UI.")
		2: print("   → You already know how to build editor plugins!")
		3: print("   → Now imagine: data tables, asset browsers, level editors...")
```

---

## All Container Locations Reference

Quick reference for all `CONTAINER_*` constants in EditorPlugin:

| Constant | Location |
|----------|----------|
| `CONTAINER_TOOLBAR` | Main toolbar (top, next to play buttons) |
| `CONTAINER_SPATIAL_EDITOR_MENU` | 3D viewport top menu bar |
| `CONTAINER_SPATIAL_EDITOR_SIDE_LEFT` | 3D viewport left sidebar |
| `CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT` | 3D viewport right sidebar |
| `CONTAINER_SPATIAL_EDITOR_BOTTOM` | 3D viewport bottom bar |
| `CONTAINER_CANVAS_EDITOR_MENU` | 2D viewport top menu bar |
| `CONTAINER_CANVAS_EDITOR_SIDE_LEFT` | 2D viewport left sidebar |
| `CONTAINER_CANVAS_EDITOR_SIDE_RIGHT` | 2D viewport right sidebar |
| `CONTAINER_CANVAS_EDITOR_BOTTOM` | 2D viewport bottom bar |
| `CONTAINER_INSPECTOR_BOTTOM` | Bottom of Inspector panel |
| `CONTAINER_PROJECT_SETTING_TAB_LEFT` | Project Settings left tabs |
| `CONTAINER_PROJECT_SETTING_TAB_RIGHT` | Project Settings right content |

---

## All Dock Slot Locations Reference

Quick reference for all `DOCK_SLOT_*` constants:

| Constant | Location |
|----------|----------|
| `DOCK_SLOT_LEFT_UL` | Left panel, upper-left tab |
| `DOCK_SLOT_LEFT_BL` | Left panel, bottom-left tab |
| `DOCK_SLOT_LEFT_UR` | Left panel, upper-right tab |
| `DOCK_SLOT_LEFT_BR` | Left panel, bottom-right tab |
| `DOCK_SLOT_RIGHT_UL` | Right panel, upper-left tab (Inspector area) |
| `DOCK_SLOT_RIGHT_BL` | Right panel, bottom-left tab |
| `DOCK_SLOT_RIGHT_UR` | Right panel, upper-right tab |
| `DOCK_SLOT_RIGHT_BR` | Right panel, bottom-right tab |

---

## Demo Script (What to Say)

1. *"Let's build a plugin in under 5 minutes. All it does is add a button."*
2. Enable plugin → Click button → "Bazinga!" appears in Output
3. *"But here's the real magic - watch what happens when I move this button..."*
4. Uncomment `DOCK_SLOT_RIGHT_UL` → Disable/Enable → Button appears near Inspector
5. Uncomment `add_control_to_bottom_panel` → Button becomes a new tab!
6. *"Every. Single. Part. Of this editor can be extended. The toolbar, the docks, the bottom panel, the inspector, the viewport - everything."*
7. *"And this is just a button. Imagine what you could build."*
