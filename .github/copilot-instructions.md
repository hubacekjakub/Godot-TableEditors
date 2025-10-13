# Godot Sheet Editor Plugin

A **Godot 4.4 Editor Plugin** for creating and editing data tables. Users can add columns/rows, save as resources, and use in-game. Future phases: CSV export, GDScript class integration.

## Code Standards

**GDScript:**
- Use `snake_case` (variables/functions), `PascalCase` (classes), `SCREAMING_SNAKE_CASE` (constants)
- Use `@tool` directive in all plugin scripts
- Prefix private functions with underscore: `func _update_ui()`
- Use explicit typing: `var sheet: Sheet`, `func get_data() -> Array`

**Plugin Structure:**
```
addons/sheet_editor/
├── plugin.cfg              # Configuration
├── sheet_editor_plugin.gd  # Main EditorPlugin class
├── sheet.gd                # Resource class (extends Resource)
```

## Task Tracking

Reference tasks from `PLAN.md` in commits: `feat: add grid (P1-004)`
- Phase 1 (Core): P1-001 to P1-018 ✅ In Progress
- Phase 2 (CSV): P2-001 to P2-018
- Phase 3 (Classes): P3-001 to P3-026
- Phase 4 (Polish): P4-001 to P4-026

**Completed:** P1-001 (plugin setup), P1-002 (dock), P1-003 (menu bar), P1-003.5 (new sheet), P1-004 (grid), P1-005 (cell editing), P1-006 (navigation), P1-007 (add column), P1-008 (column naming), P1-009 (column deletion), P1-012 (add row), P1-013 (row naming), P1-014 (row deletion), P1-016 (Sheet resource class)
**Next:** P1-017 (save functionality), P1-018 (load functionality)

## Key Patterns

**Sheet Resource:**
```gdscript
@export var columns: Array[Dictionary] = []  # {name: String, type: String, default: Variant}
@export var rows: Array[Dictionary] = []     # {id: int, cells: Array}
@export var sheet_name: String = "Untitled"
```

**Editor Integration:**
- Bottom panel dock: `add_control_to_bottom_panel(dock, "Sheet Editor")`
- Detect Sheet resources: `func _handles(obj: Object) -> bool` (check `obj is Sheet`)
- Display/edit: `func _edit(obj: Object) -> void` (update dock UI)

**UI Creation:**
```gdscript
var vbox := VBoxContainer.new()
var menu_bar := MenuBar.new()
var grid := GridContainer.new()
grid.columns = sheet.column_count
# Add LineEdit for each cell
```

**Save/Load:**
```gdscript
ResourceSaver.save(sheet, path)
ResourceLoader.load(path) as Sheet
```

## Testing

- Test in Godot Editor with various data types
- Verify save/load with .tres files
- Test 100+ row datasets for performance
- Update PLAN.md checkboxes when tasks complete

