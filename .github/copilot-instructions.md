# Godot Sheet Editor - 3 Independent Plugins (Godot 4.4+)

**Project:** Academic research - 3 distinct editor-based data management approaches.

## Plugins

1. **Spreadsheet** (`sheet_editor/`) ✅ - Excel-style, CSV export/import
2. **Class Table** (`class_table_editor/`) ✅ - Type-safe GDScript class tables, TableHandle system
3. **Resource Collection** (`resource_collection_editor/`) ⏳ - Bulk `.tres` editing

**Key:** Zero shared code. Completely independent.

## Architecture Patterns

**EditorPlugin Lifecycle:** `_enter_tree()` → create dock → `_handles()` → `_edit()`

**Cell Storage:** Sparse dictionary `cells["row,col"] = value` (memory efficient)

### Plugin 2: Type-Safe Patterns

**PropertyInspector:** Uses `Script.get_script_property_list()` - NO regex
**TableHandle:** `handle.get_data(MyClass)` - Reflection-based conversion
**ClassCache:** Mtime-based invalidation for performance
**Types:** 34+ Godot types (primitives, Vector2/3, Color, Resources)

## Standards

**Naming:** `snake_case` vars/funcs, `PascalCase` classes, `SCREAMING_SNAKE` constants
**Required:** `@tool` directive, explicit typing, underscore for private
**Structure:** `plugin.cfg` → `main_plugin.gd` (EditorPlugin) → `dock_ui.gd/tscn` → `resource.gd`

## Workflows

**Tests:** Open `scenes/TestRunner.tscn` → F5 → Check Output
**Commits:** `feat: description (P2-XXX)` format
**Tasks:** P1-001–026 ✅ | P2-001–110 (Core ✅) | P3-001–026
**Debug:** VS Code tasks: Run/Debug Godot, Run Game, Remote Debug

## Plugin 2 Details

**Why Native API?** Accurate, fast, type-safe (vs regex). Limitation: file-based only
**ResourceConverter:** Auto-maps properties via reflection (`handle.get_data(Class)`)
**Type Metadata:** `columns_metadata[col]` stores {name, type, type_name, default, hint}

## Common Issues

**Plugin not loading:** Check `plugin.cfg` script name matches exactly
**_handles() failing:** Use `obj is YourResource` not `get_class()`
**CSV escaping:** Wrap commas/quotes: `"value \"quoted\""`
**Performance:** Use sparse dict `cells["row,col"]` not 2D arrays

## Usage

**P1:** `sheet.get_cell(row, col)` - Manual access
**P2:** `handle.get_data(Class)` - Type-safe conversion

## Reference

**Core:** `spreadsheet_plugin.gd`, `class_table_resource.gd`, `property_inspector.gd`
**Docs:** `README.md`, `PLAN.md`, `addons/class_table_editor/README.md`

