# Class Table Editor Plugin

A **Godot 4.4+ Editor Plugin** for creating and editing type-safe data tables. Define a GDScript resource class, auto-generate a spreadsheet-like editor, and use TableHandles to reference rows in your game code.

## Quick Start

### 1. Create a Data Class
```gdscript
# MyUnitClass.gd
extends Resource
class_name MyUnit

@export var unit_name: String = "Unit"
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var movement_speed: float = 5.0
```

### 2. Generate a Table
1. Open the **Class Table Editor** dock (bottom panel)
2. Click **"New Table from Class"**
3. Select your class (e.g., `MyUnit`)
4. Table columns auto-generate from properties
5. Add rows and edit data
6. Save as `my_units.tres`

### 3. Use in Code
```gdscript
# In your scene script
@export var unit_handle: TableHandle

func _ready():
    var unit_data = unit_handle.get_data(MyUnit) as MyUnit
    print(unit_data.unit_name)  # Access properties
    print(unit_data.max_health)
```

## Features

✅ **Type Safety** - Properties validated at edit time
✅ **Designer Workflow** - Non-programmers can edit data
✅ **Auto-Generation** - Columns generated from @export properties
✅ **TableHandles** - Persistent row references
✅ **Inspector Integration** - Easy property assignment
✅ **Version Control** - Text-based .tres files

## Architecture

```
Your Resource Class (@export properties)
           ↓
ClassTable Resource (.tres file)
           ↓
TableHandle (Row reference)
           ↓
Game Code (Type-safe data access)
```

## Folder Structure

```
addons/class_table_editor/
├── README.md                    # This file
├── plugin.cfg                   # Plugin manifest
├── core/                        # Core classes
│   ├── class_table_plugin.gd   # Main plugin class
│   └── class_table_resource.gd # ClassTable resource definition
├── ui/                          # User interface
│   ├── class_table_dock.gd     # Main editor dock
│   └── class_selection_dialog.gd
├── editors/                     # Cell editing
│   ├── cell_manager.gd
│   └── typed_cell_editor.gd
├── inspector_plugins/           # Inspector integration
│   ├── table_handle.gd         # TableHandle resource
│   └── table_handle_inspector_plugin.gd
├── inspection/                  # Class parsing & caching
│   ├── class_cache.gd
│   ├── class_inspector.gd
│   └── property_inspector.gd
├── utils/                       # Utilities
│   ├── class_selector.gd
│   ├── grid_builder.gd
│   ├── resource_converter.gd
│   └── typed_cell_editor_factory.gd
└── example/                     # Complete working example
    ├── BaseUnit.gd
    ├── base_units_table.tres
    ├── UnitSpawner.tscn
    ├── UnitSpawner.gd
    └── README.md               # Example documentation
```

## Core Concepts

### ClassTable Resource
A `.tres` file containing:
- Column metadata (types, names, defaults)
- Row data (cell values)
- Source class reference
- Type information

### TableHandle
A persistent reference to a row:
- Stores table path + row ID
- Type-safe data access via `get_data()`
- Works even if table is reordered
- Inspector-integrated for easy assignment

### Type Support
| Type | Example |
|------|---------|
| String | "Knight" |
| int | 150 |
| float | 3.5 |
| bool | true |
| Color | Color(1, 0, 0, 1) |
| Vector2 | Vector2(10, 20) |
| Vector3 | Vector3(0, 1, 0) |

## How to Use

### Step 1: Define Your Resource
```gdscript
extends Resource
class_name Item

@export var item_name: String = "Item"
@export var item_type: String = "Weapon"
@export var price: int = 100
@export var item_color: Color = Color.WHITE
```

### Step 2: Create Table
1. Open Class Table Editor
2. Click "New Table from Class"
3. Select `Item`
4. Edit rows (add items, set values)
5. Save as `items_table.tres`

### Step 3: Use TableHandles
1. In your scene, add an @export TableHandle property
2. In Inspector, assign handle to table row
3. In code: `var item = handle.get_data(Item) as Item`

### Step 4: Access Data
```gdscript
func display_item(handle: TableHandle) -> void:
    var item = handle.get_data(Item) as Item
    print("%s: $%d" % [item.item_name, item.price])
```

## Complete Example

See the `example/` folder for a full working implementation:
- **BaseUnit.gd** - Resource class
- **base_units_table.tres** - Pre-configured table
- **UnitSpawner.tscn** - Demo scene
- **UnitSpawner.gd** - Usage example
- **README.md** - Detailed walkthrough

### Run the Example
1. Open `example/UnitSpawner.tscn`
2. Assign TableHandles in Inspector
3. Press F6 to run
4. See 4 colored units with stats

## Key Benefits

1. **Type Safety** - Invalid values caught at edit time
2. **Designer Friendly** - Non-programmers edit data spreadsheet-style
3. **Scalable** - Handles 10 units or 10,000 units equally
4. **Maintainable** - Property changes auto-propagate
5. **Git Friendly** - Text-based .tres resources
6. **Performance** - Efficient data loading at runtime

## Troubleshooting

**Table not showing properties?**
- Ensure class has `@export` decorators
- Reload the Class Table Editor dock
- Check that class extends `Resource`

**TableHandle assignment not working?**
- Plugin must be enabled (Project → Settings → Plugins)
- Table must have data rows
- Use "Quick Load" in Inspector

**Data not loading?**
- Save table with Class Table Editor (not manual save)
- Check .tres file format is valid
- Verify `get_data()` has correct class type

## Related Resources

- **Godot Docs**: [Resources](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html), [@export](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html)
- **Example Docs**: See `example/README.md` for detailed walkthrough

## Best Practices

1. Use descriptive property names
2. Provide sensible default values
3. Keep tables focused (one class per table)
4. Use TableHandles instead of row indices
5. Version control .tres files (they're text-based)
6. Test with `example/ExampleTest.tscn`

## Learning Path

1. Read this README
2. Check the example (run UnitSpawner.tscn)
3. Create your own resource class
4. Generate a table from it
5. Use TableHandles in your scenes
6. Extend with more properties

## 📌 Version Info

- **Godot Version**: 4.4+
- **Plugin Type**: Editor Plugin
- **Status**: Feature Complete
- **Phase**: Phase 2 (Class Integration)

---

**Ready to use type-safe tables in your game?** Start with the example or create your own resource class!
