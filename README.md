# Godot Sheet Editor - 3 Independent Plugins

**Academic research project** exploring three distinct approaches to editor-based data management in Godot 4.4+.

## Plugins

### 1. **Spreadsheet Editor** (`sheet_editor/`) ✅ COMPLETE
Excel-style data tables with CSV export/import

**Features:**
- Manual column/row creation
- CSV import/export (compatible with Excel, Google Sheets)
- Save as `.tres` resources
- No code required

**Use:** Item lists, config data, dialogue trees

### 2. **Class Table Editor** (`class_table_editor/`) ✅ CORE COMPLETE
Type-safe tables generated from GDScript classes

**Features:**
- Auto-generate columns from `@export` properties
- 34+ Godot types supported (primitives, Vector2/3, Color, Resources)
- **TableHandle system** - persistent row references with reflection-based conversion
- **CSV with type hints** - `name:String,damage:int,speed:float`
- Native PropertyInspector API (no regex parsing)

**Use:** Type-enforced data mirroring game classes

**Example:**
```gdscript
# Game code
@export var unit_handle: TableHandle
var unit = unit_handle.to_resource(BaseUnit) as BaseUnit
print(unit.max_health)  # Full type safety
```

### 3. **Resource Collection Editor** (`resource_collection_editor/`) ⏳ PLANNED
Bulk editing of multiple `.tres` files in unified table view

**Use:** Managing collections of similar resources

## Quick Start

1. Copy `addons/` folder to your project
2. Enable plugins in **Project Settings > Plugins**
3. Access editors from bottom panel dock

**Plugin 1:** Create tables manually, export to CSV
**Plugin 2:** Select GDScript class → auto-generate typed table → use TableHandles in game

## CSV Formats

### Plugin 1 - Simple CSV
```csv
Name,Health,Speed
Knight,100,5.5
Archer,75,6.2
```

### Plugin 2 - Type-Preserving CSV
```csv
name:String,damage:int,speed:float,is_boss:bool
Knight,100,5.5,false
Dragon,500,3.8,true
```
- Type hints in headers
- Automatic metadata reconstruction on import
- CSV injection prevention

## Architecture

**Zero Shared Code:** Each plugin is completely independent

**Cell Storage:** Sparse dictionary `cells["row,col"] = value`

**Plugin 2 Unique:**
- `PropertyInspector` - Native `Script.get_script_property_list()` API
- `TableHandle` - Inspector-integrated row references
- `ResourceConverter` - Reflection-based property mapping
- `ClassCache` - Mtime-based invalidation

## Development

**Tests:** Open `scenes/TestRunner.tscn` → F5 → Check Output

**VS Code Tasks:**
- `Ctrl+Shift+B` - Run Godot Editor
- Run Game, Debug, Remote Debug available

**Standards:**
- `snake_case` for vars/funcs, `PascalCase` for classes
- `@tool` directive required in plugins
- Explicit typing everywhere

**Commits:** `feat: description (P2-XXX)`

## Project Structure

```
addons/
├── sheet_editor/              # Plugin 1: Spreadsheet ✅
├── class_table_editor/        # Plugin 2: Class Table ✅
└── resource_collection_editor/# Plugin 3: Resource Editor ⏳
scripts/                        # Tests
scenes/TestRunner.tscn         # Test runner
docs/                          # Documentation
```

**Status:**
- Plugin 1: ✅ Complete (P1-001 to P1-026)
- Plugin 2: ✅ Core Complete (P2-001 to P2-066)
- Plugin 3: ⏳ Planned (P3-001 to P3-026)

See [PLAN.md](PLAN.md) for task tracking.

## License

MIT License - Free to use, modify, and distribute.

## Links

- [PLAN.md](PLAN.md) - Development roadmap
- [Plugin 2 README](addons/class_table_editor/README.md) - Class Table usage guide
- [Example Walkthrough](addons/class_table_editor/example/README.md) - Working example
