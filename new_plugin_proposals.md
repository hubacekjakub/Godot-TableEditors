# New Plugin Proposals - Academic Research Extensions

**Date:** November 13, 2025
**Status:** Conceptual Phase
**Purpose:** Additional editor plugins for research and practical workflows

---

## Quick Overview

- **Plugin 4 – Dev Notes:** Simple per-project editor dock for TODOs and notes, persisted in `EditorSettings`.
- **Plugin 5 – Batch Resource Editor:** Bulk edit operations for many resources of the same type with undo/redo.
- **Plugin 6 – Scene Notes:** Scene-specific notes stored with each `.tscn`, visible when the scene is open in the editor.

---

## Plugin 4: Editor Notepad (Dev Notes Manager)

### Concept & Use
Lightweight dock for quick development notes and TODOs. Notes are per-project and persist across editor sessions using `EditorSettings`.

- **Academic:** Show `EditorSettings` + custom dock lifecycle.
- **Practical:** Capture “what to do next” without leaving Godot.

### Core Features (Short)

1. **List-based notes** – One-line entries with optional checkbox and timestamp.
2. **Persistence via `EditorSettings`** – Load/save automatically on editor open/close.
3. **Per-project isolation** – Key includes a project hash so projects don’t share notes.

### Technical Architecture

```
addons/dev_notes/
├── plugin.cfg
├── dev_notes_plugin.gd         # EditorPlugin entry point
├── dev_notes_dock.gd            # Main UI dock
├── dev_notes_dock.tscn          # Dock layout
├── note_item.gd                 # Single note UI component
└── README.md
```

**Key Pieces:**

```gdscript
# dev_notes_plugin.gd
@tool
extends EditorPlugin

var dock: DevNotesDock

func _enter_tree():
    dock = preload("res://addons/dev_notes/dev_notes_dock.tscn").instantiate()
    add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
    dock.load_notes()

func _exit_tree():
    dock.save_notes()
    remove_control_from_docks(dock)
    dock.queue_free()
```

```gdscript
# dev_notes_dock.gd
@tool
extends VBoxContainer

var notes: Array[Dictionary] = []  # {text, checked, timestamp}

func _get_project_key() -> String:
    var project_path = ProjectSettings.globalize_path("res://")
    return "dev_notes/project_%d" % project_path.hash()

func load_notes():
    notes = EditorSettings.get_setting(_get_project_key(), [])
    _rebuild_ui()

func save_notes():
    EditorSettings.set_setting(_get_project_key(), notes)
```

### UI Design

```
┌──────────────────────────────────────┐
│ Dev Notes                       [+]  │
├──────────────────────────────────────┤
│ [New note...________________] [Add] │
├──────────────────────────────────────┤
│ ☐ Fix player movement bug       [X] │
│   Nov 13, 14:32                      │
├──────────────────────────────────────┤
│ ☑ Add health bar UI              [X] │
│   Nov 13, 10:15                      │
├──────────────────────────────────────┤
│ ☐ Implement save system          [X] │
│   Nov 12, 16:45                      │
├──────────────────────────────────────┤
│ 3 notes (1 completed)                │
└──────────────────────────────────────┘
```

### Optional Extras

- Categories/tags (TODO/FIXME/IDEA).
- Search/filter and “only unchecked” view.
- Export to Markdown/clipboard.
- Due dates + simple highlighting for overdue items.

### Academic Value & Effort

- Teaches `EditorSettings`, custom docks, simple CRUD UI.
- Good first-week exercise: minimal version is **TextEdit + Save/Load**, ~50 LOC.

---

## Plugin 5: Batch Resource Editor

### Concept & Use
Bulk operations on multiple resources of the same type.

- **Academic:** Reflection, `get_property_list()`, batch processing, undo/redo.
- **Practical:** Adjust enemy stats, tweak materials, rename content in bulk.

### Core Features (Short)

1. **Resource selection** – File browser + drag-and-drop, filter by type.
2. **Common property view** – Show only fields present on all selected resources.
3. **Batch operations** – Set/add/multiply values, find&replace strings, reset to defaults.
4. **Undo/Redo + preview** – Use `EditorUndoRedoManager` with optional dry-run.

### Technical Architecture

```
addons/batch_resource_editor/
├── plugin.cfg
├── batch_editor_plugin.gd       # EditorPlugin entry point
├── batch_editor_dock.gd         # Main UI dock
├── batch_editor_dock.tscn       # Dock layout
├── resource_list_panel.gd       # Left panel: resource list
├── property_editor_panel.gd     # Right panel: property editing
├── batch_operation.gd           # Operation base class
├── operations/
│   ├── set_property_op.gd
│   ├── multiply_property_op.gd
│   ├── find_replace_op.gd
│   └── reset_property_op.gd
└── README.md
```

**Core Structure:**

```gdscript
# batch_editor_plugin.gd
@tool
extends EditorPlugin

var dock: BatchEditorDock

func _enter_tree():
    dock = preload("res://addons/batch_resource_editor/batch_editor_dock.tscn").instantiate()
    add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
    dock.set_undo_redo(get_undo_redo())
```

```gdscript
# batch_operation.gd
@tool
extends RefCounted
class_name BatchOperation

var property_name: String

func get_operation_name() -> String:
    return "Unknown Operation"

func calculate_new_value(old_value: Variant) -> Variant:
    return old_value
```

### UI Design

```
┌────────────────────────────────────────────────────────────┐
│ Batch Resource Editor                                       │
├──────────────────────┬─────────────────────────────────────┤
│ Resources (5)        │ Properties                          │
│                      │                                     │
│ [Add Files...]       │ ▼ Common Properties                 │
│ [Add Folder...]      │                                     │
│ [Clear All]          │ max_health: int                     │
│                      │ [100        ] [Set] [+10] [×1.5]   │
│ ☑ enemy_goblin.tres  │                                     │
│ ☑ enemy_orc.tres     │ attack_damage: int                  │
│ ☑ enemy_troll.tres   │ [15         ] [Set] [+5] [×2.0]    │
│ ☑ enemy_dragon.tres  │                                     │
│ ☑ enemy_slime.tres   │ movement_speed: float               │
│                      │ [5.0        ] [Set] [+1] [×1.2]    │
│ Filter: [Enemy_____] │                                     │
│ Type: [BaseUnit  ▼]  │ ▼ Differing Properties              │
│                      │ description: String                 │
│                      │ (5 different values)                │
│                      │ [Find/Replace...]                   │
│                      │                                     │
│                      │ ▼ Batch Operations                  │
│                      │ [Reset All to Defaults]             │
│                      │ [Copy From... ▼]                    │
│                      │ [Export Changes as CSV]             │
├──────────────────────┴─────────────────────────────────────┤
│ 5 resources selected                          [Apply All]  │
└────────────────────────────────────────────────────────────┘
```

### Batch Operation Examples

#### 1. Multiply All Enemy Health by 1.5
```gdscript
var op = MultiplyPropertyOp.new("max_health", 1.5)
batch_editor.apply_batch_operation(op)
```

#### 2. Set All Materials to Same Shader
```gdscript
var shader = load("res://shaders/my_shader.gdshader")
var op = SetPropertyOp.new("shader", shader)
batch_editor.apply_batch_operation(op)
```

#### 3. Add 10 to All Prices
```gdscript
var op = AddPropertyOp.new("price", 10)
batch_editor.apply_batch_operation(op)
```

#### 4. Find/Replace in Descriptions
```gdscript
var op = FindReplaceOp.new("description", "old text", "new text")
batch_editor.apply_batch_operation(op)
```

### Academic Value & Effort

- Teaches reflection, dynamic property access, command pattern, and editor undo/redo.
- MVP: hard-coded type + simple “set property for all” operation, no undo/redo (~200 LOC).

---

## Plugin 6: Scene Notes

### Concept & Feasibility
Scene-specific notes that are saved with each `.tscn` file and appear when that scene is active in the editor.

**How to store notes:**

- Godot allows extra nodes/resources in the scene tree.
- We can add a custom `SceneNotes` node at the root (or as a child) with exported `text`/`items`.
- Alternatively, attach a script to the root and store notes as exported properties.

```gdscript
# scene_notes.gd
@tool
extends Node
class_name SceneNotes

@export_multiline var notes: String = ""  # or Array[String] for list
```

The plugin ensures one `SceneNotes` node per edited scene and exposes its contents in a dock.

### UX

- Dock shows a multiline editor or list of bullets for the current scene.
- When you switch scenes, the dock automatically switches to that scene’s notes.
- If a scene has no `SceneNotes` node, the dock can offer a **“Create Scene Notes”** button.

### Core Flow

```gdscript
# scene_notes_plugin.gd
@tool
extends EditorPlugin

var dock: SceneNotesDock

func _enter_tree():
     dock = preload("res://addons/scene_notes/scene_notes_dock.tscn").instantiate()
     add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
     get_editor_interface().get_scene_tree_dock().tree_changed.connect(dock.on_scene_changed)
```

The dock then finds/creates `SceneNotes` in the current scene and binds its UI to `notes`.

### Academic Value & Contrast

- Shows difference between **global EditorSettings notes (Plugin 4)** and **resource-embedded notes (Plugin 6)**.
- Demonstrates working with the current edited scene, nodes, and serialized properties.

---

---

## Integration with Existing Project (Short)

### Project Structure Update

```
Godot-SheetEditor/
├── addons/
│   ├── class_table_editor/      # Plugin 2 (existing)
│   ├── resource_collection_editor/  # Plugin 3 (existing)
│   ├── sheet_editor/            # Plugin 1 (existing)
│   ├── dev_notes/               # Plugin 4 (NEW)
│   └── batch_resource_editor/   # Plugin 5 (NEW)
```

### Academic Research Value

| Plugin | Complexity | Focus | Use Case |
|--------|-----------|-------|----------|
| Sheet Editor | ⭐⭐⭐ | Custom resources, CSV, grid UI | Excel-like data |
| Class Table Editor | ⭐⭐⭐⭐ | Reflection, type safety | Type-safe tables |
| Resource Collection | ⭐⭐⭐ | Bulk `.tres` editing | Multi-file editing |
| Dev Notes | ⭐⭐ | EditorSettings, docks | Per-project notes |
| Scene Notes | ⭐⭐⭐ | Scene API, serialization | Per-scene notes |
| Batch Editor | ⭐⭐⭐⭐ | Reflection, undo/redo, ops | Bulk resource edits |

### Synergies Between Plugins

**Dev Notes + Others:**
- Quick TODOs while working on other plugins
- Track tasks for plugin development itself

**Class Table + Batch Editor:**
```gdscript
# Create table with Class Table Editor
var unit_table = ClassTableResource.new()

# Export rows as BaseUnit resources
for row in unit_table.row_count:
    var handle = unit_table.create_handle(row)
    var unit = handle.build(BaseUnit)
    ResourceSaver.save(unit, "res://units/unit_%d.tres" % row)

# Use Batch Editor to modify all exported units
# Select all units/*.tres → multiply max_health by 1.5
```

**Sheet Editor + Batch Editor:**
- Export from Sheet → Individual .tres files
- Batch edit those files
- Reimport to Sheet (if needed)

---

## Comparison Table

| Feature | Dev Notes | Batch Editor | Class Table | Sheet Editor |
|---------|-----------|--------------|-------------|--------------|
| **Persistence** | EditorSettings | ResourceSaver | .tres file | .tres file + CSV |
| **Data Structure** | Array of Dicts | Resource properties | Typed class rows | String grid |
| **UI Paradigm** | List/TODO | Split panel inspector | Spreadsheet grid | Spreadsheet grid |
| **Complexity** | Low | High | High | Medium |
| **Undo/Redo** | No | Yes | Yes | Yes |
| **Academic Focus** | Settings API | Reflection + Batch ops | Type safety | Grid UI + CSV |
| **Practical Use** | Developer notes | Asset management | Game data | Quick data entry |

---

## Implementation Priorities (High Level)

- **Teaching-focused order:** Dev Notes → Scene Notes → Sheet Editor → Class Table Editor → Batch Editor → Resource Collection.
- **Practical impact:** Class Table + Batch Editor first for real projects; notes plugins as QoL.

---

## Next Steps

- Decide which plugin to implement first for the course vs for real projects.
- Move detailed task breakdowns into `PLAN.md` once priorities are locked in.
