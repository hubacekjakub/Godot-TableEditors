# Implementation 2: GDScript Class Integration - Detailed Plan

**Approach**: Automatically generate and maintain data tables based on GDScript class definitions.

**Use Case**: Type-safe data management where the table structure mirrors a GDScript class. For example, an `ItemData` class with properties like `name: String`, `damage: int`, `icon: Texture2D` generates a table with corresponding columns. Changes to the class can update the table structure.

**Key Features**:
- Parse GDScript classes and extract typed properties
- Generate table columns from class properties
- Bidirectional sync: class → table and table → class
- Type enforcement based on GDScript types
- CSV export/import with type preservation
- Runtime data access with multiple usage patterns
- Completely separate codebase from Implementation 1

**Status**: Not started. Will begin with copying Implementation 1 files.

**Note**: This implementation will have its own dialogs, dock UI, and all necessary code duplicated and adapted from Implementation 1. No code sharing between implementations to maintain independence.

---

## Example Workflow

### 1. Create Data Class
```gdscript
# res://scripts/EnemyData.gd
class_name EnemyData
extends Resource

@export var health: int = 100
@export var damage: int = 10
@export var defense: int = 5
@export var luck: float = 0.5
@export var agility: bool = false
```

### 2. Create Table from Class
- Open "Class Table" dock
- Click "New Table from Class"
- Select `EnemyData.gd`
- Name table: "Enemy Stats"
- Save as: `res://data/enemy_stats.tres`

### 3. Populate Data
Add rows for different enemies:
| Row Name | health | damage | defense | luck | agility |
|----------|--------|--------|---------|------|---------|
| Goblin   | 50     | 8      | 3       | 0.3  | true    |
| Dragon   | 500    | 100    | 50      | 0.8  | false   |
| Slime    | 20     | 2      | 1       | 0.1  | true    |

### 4. Runtime Usage Options

**Option A: Direct Table Access (Simple)**
```gdscript
@export var enemy_table: ClassTableResource
@export var enemy_id: String = "Goblin"

func _ready():
    var stats = enemy_table.get_row_data(enemy_id)
    health = stats["health"]  # Dictionary-based
```

**Option B: Typed Resource Access (Type-Safe)**
```gdscript
@export var enemy_table: ClassTableResource
@export var enemy_id: String = "Goblin"

func _ready():
    var enemy: EnemyData = enemy_table.get_row_as_resource(enemy_id)
    health = enemy.health  # Fully typed!
```

**Option C: Generated Resource Files (Native Godot)**
```gdscript
# After table creation, export individual resources
# Creates: enemy_goblin.tres, enemy_dragon.tres, etc.

@export var enemy_data: EnemyData  # Direct resource reference

func _ready():
    health = enemy_data.health  # Type-safe, autocomplete works
```

**Option D: Custom Export Plugin (Advanced - Future Enhancement)**
```gdscript
# Custom @export annotation that shows dropdown of row names
@export var enemy_table: ClassTableResource
@export_table_row("enemy_table") var enemy_id: String  # Dropdown in inspector!
```

**Recommendation**: Implement Options A, B, and C in Phase 8. Option D is a Phase 4 (Polish) enhancement.

---

## Phase 1: Foundation & Code Duplication (P2-001 to P2-012)

**Goal**: Set up the basic infrastructure by copying Implementation 1 files and adapting them for class-based table editing.

**Timeline**: 2-3 days

### Initial Setup (P2-001 to P2-006)

- [x] **P2-001**: Create `class_table/` folder structure
  - Create `addons/sheet_editor/class_table/` directory
  - Set up basic folder organization

- [x] **P2-002**: Copy and rename `spreadsheet_dock.gd` → `class_table_dock.gd`
  - Copy the entire file
  - Update class name to `ClassTableDock`
  - Update all internal references

- [x] **P2-003**: Copy and rename `spreadsheet_dock.tscn` → `class_table_dock.tscn`
  - Copy scene file
  - Update script reference to `class_table_dock.gd`
  - Preserve all UI layout

- [x] **P2-004**: Copy and rename `spreadsheet_resource.gd` → `class_table_resource.gd`
  - Copy resource class
  - Update class name to `ClassTableResource`
  - Keep all existing properties for now

- [x] **P2-005**: Copy `create_table_dialog.gd` → `class_select_dialog.gd`
  - Copy dialog script
  - Update class name to `ClassSelectDialog`
  - Will be heavily modified later

- [x] **P2-006**: Copy `create_table_dialog.tscn` → `class_select_dialog.tscn`
  - Copy dialog scene
  - Update script reference to `class_select_dialog.gd`

### Plugin Integration (P2-007 to P2-009)

**Note**: Both implementations will run simultaneously as separate docks. Each handles its own resource type:
- `SpreadsheetPlugin` handles `SpreadsheetResource` → "Sheet Editor" dock
- `ClassTablePlugin` handles `ClassTableResource` → "Class Table" dock

- [x] **P2-007**: Create `class_table_plugin.gd` (EditorPlugin entry point)
  - Extend `EditorPlugin`
  - Implement `_enter_tree()` and `_exit_tree()`
  - Load `class_table_dock.tscn`
  - Add separate dock to bottom panel with "Class Table" label
  - Similar structure to `spreadsheet_plugin.gd` but for `ClassTableResource`

- [x] **P2-008**: Update `plugin.cfg` to load both plugins
  - Keep `spreadsheet/spreadsheet_plugin.gd` as main entry point
  - Have spreadsheet plugin instantiate and manage class_table plugin
  - Both plugins active simultaneously
  - Each plugin only handles its specific resource type via `_handles()`

- [x] **P2-009**: Implement resource type detection for both plugins
  - `SpreadsheetPlugin._handles()` returns true only for `SpreadsheetResource`
  - `ClassTablePlugin._handles()` returns true only for `ClassTableResource`
  - Test that clicking each resource type opens the correct dock
  - Verify both docks can be visible simultaneously

### Basic Adaptation (P2-010 to P2-012)

- [ ] **P2-010**: Update `class_table_resource.gd` to include `source_class_path: String` property
  - Add `@export var source_class_path: String = ""`
  - Add metadata for class modification tracking
  - Keep backward compatibility with spreadsheet resource structure

- [ ] **P2-011**: Modify `class_table_dock.gd` to disable manual column/row creation initially
  - Comment out or hide "Add Column" button
  - Comment out or hide "Add Row" button
  - Keep the UI code for later re-enabling

- [ ] **P2-012**: Test that copied implementation displays and edits existing tables
  - Load an existing spreadsheet resource
  - Verify grid displays correctly
  - Test cell editing still works
  - Ensure no crashes or errors

---

## Phase 2: GDScript Class Parser (P2-013 to P2-025)

**Goal**: Build the core functionality to parse GDScript class files and extract property information.

**Timeline**: 4-5 days

### File Parsing Foundation (P2-013 to P2-016)

- [ ] **P2-013**: Create `class_parser.gd` utility class
  - Create new static class or singleton
  - Add basic structure with parse methods

- [ ] **P2-014**: Implement file reading and basic syntax validation
  - Read .gd file using `FileAccess.open()`
  - Check for valid GDScript syntax markers
  - Return error if file cannot be parsed

- [ ] **P2-015**: Parse class declaration (`class_name` or `extends Resource`)
  - Use regex to find `class_name ClassName`
  - Parse `extends Resource` or `extends RefCounted`
  - Validate class is usable for data tables

- [ ] **P2-016**: Extract class name from file if not using `class_name`
  - Use filename as fallback (e.g., `ItemData.gd` → `ItemData`)
  - Store class name for later use

### Property Extraction (P2-017 to P2-021)

- [ ] **P2-017**: Detect `@export` annotated variables
  - Use regex to find lines starting with `@export`
  - Parse following line for variable declaration
  - Skip non-exported variables initially

- [ ] **P2-018**: Parse type hints (`: int`, `: String`, etc.)
  - Extract type from `var name: Type` syntax
  - Handle optional type hints
  - Store type as string for now

- [ ] **P2-019**: Extract default values (`= 0`, `= ""`, etc.)
  - Parse assignment operator and value
  - Handle various literal types (numbers, strings, bools)
  - Store as Variant

- [ ] **P2-020**: Support both `var name: Type` and `var name := value` syntax
  - Parse type inference from `:=` operator
  - Deduce type from default value when possible
  - Handle edge cases

- [ ] **P2-021**: Create PropertyInfo dictionary structure
  - Define structure: `{name: String, type: String, default_value: Variant, is_exported: bool}`
  - Return array of PropertyInfo dictionaries
  - Add validation and error handling

### Basic Type Support (P2-022 to P2-025)

- [ ] **P2-022**: Support `int` type parsing and validation
  - Recognize `int` type hint
  - Validate default values are integers
  - Handle edge cases (INT_MAX, negative values)

- [ ] **P2-023**: Support `float` type parsing and validation
  - Recognize `float` type hint
  - Validate default values are floats
  - Handle scientific notation

- [ ] **P2-024**: Support `bool` type parsing and validation
  - Recognize `bool` type hint
  - Validate default values (true/false)
  - Handle capitalization variants

- [ ] **P2-025**: Support `String` type parsing and validation
  - Recognize `String` type hint
  - Validate default string literals
  - Handle empty strings and quotes

---

## Phase 3: Class-to-Table Generation (P2-026 to P2-038)

**Goal**: Generate table structures from parsed class definitions and create the UI for class selection.

**Timeline**: 4-5 days

### Class Selection Dialog (P2-026 to P2-031)

- [ ] **P2-026**: Adapt `class_select_dialog.gd` to show file picker for .gd files
  - Remove existing table creation UI
  - Add file path label/line edit
  - Prepare for FileDialog integration

- [ ] **P2-027**: Add FileDialog for browsing GDScript files
  - Create FileDialog with `.gd` filter
  - Connect to "Browse" button
  - Handle file selection

- [ ] **P2-028**: Display selected class path in dialog
  - Update label with selected path
  - Show relative path from project root
  - Validate file exists

- [ ] **P2-029**: Add "Parse Class" button to analyze selected file
  - Connect button to parser
  - Show loading/progress indicator
  - Handle parse errors gracefully

- [ ] **P2-030**: Display detected properties in a list (name, type, default)
  - Create ItemList or Tree control
  - Format: "name (Type) = default"
  - Color-code by type

- [ ] **P2-031**: Add "Create Table" button to generate resource from class
  - Enable only after successful parse
  - Connect to table generation logic
  - Close dialog on success

### Table Structure Generation (P2-032 to P2-038)

- [ ] **P2-032**: Convert parsed properties to column definitions
  - Map PropertyInfo array to column structure
  - Use existing spreadsheet column format
  - Maintain compatibility

- [ ] **P2-033**: Map GDScript types to internal column types
  - Create type mapping: `int→INT`, `String→STRING`, `float→FLOAT`, `bool→BOOL`
  - Add type enum if needed
  - Handle unknown types gracefully

- [ ] **P2-034**: Set column default values from class defaults
  - Copy default_value from PropertyInfo
  - Convert to appropriate format
  - Handle null/empty defaults

- [ ] **P2-035**: Create empty `class_table_resource` with class-derived structure
  - Instantiate ClassTableResource
  - Set columns from parsed properties
  - Initialize empty rows array

- [ ] **P2-036**: Store source class path in resource metadata
  - Set `source_class_path` property
  - Add metadata for modification tracking
  - Store original PropertyInfo for sync

- [ ] **P2-037**: Display generated table in dock with read-only column headers
  - Update grid in class_table_dock
  - Make column names read-only
  - Show type indicators

- [ ] **P2-038**: Test: Create table from simple class with 3-4 basic typed properties
  - Create test class: ItemData with name, damage, cost, stackable
  - Parse and generate table
  - Verify structure is correct
  - Test adding rows with typed defaults

---

## Phase 4: Type-Safe Editing (P2-039 to P2-048)

**Goal**: Enforce type constraints when editing cells based on class property types.

**Timeline**: 4-5 days

### Type Validation (P2-039 to P2-043)

- [ ] **P2-039**: Create `type_validator.gd` utility class
  - Static methods for each type
  - Return validation result + error message
  - Reusable across the plugin

- [ ] **P2-040**: Implement int validation (reject non-numeric input)
  - Check `is_valid_int()` method
  - Handle negative numbers
  - Return converted int or error

- [ ] **P2-041**: Implement float validation (accept decimal points)
  - Check `is_valid_float()` method
  - Handle scientific notation
  - Return converted float or error

- [ ] **P2-042**: Implement bool validation (checkbox or dropdown: true/false)
  - Parse "true"/"false" strings (case-insensitive)
  - Accept 0/1 as bool
  - Return converted bool or error

- [ ] **P2-043**: Implement String validation (accept any text)
  - Always valid (no special validation)
  - Trim whitespace option
  - Handle quotes and escape sequences

### Cell Editing with Type Enforcement (P2-044 to P2-048)

- [ ] **P2-044**: Modify cell editors to use type-specific controls
  - LineEdit for strings (with validation)
  - SpinBox for int (min/max limits)
  - SpinBox for float (step size)
  - CheckBox or OptionButton for bool

- [ ] **P2-045**: Show validation errors when invalid data is entered
  - Display tooltip or inline error
  - Red border on invalid input
  - Clear error on valid input

- [ ] **P2-046**: Prevent saving invalid data (revert to previous value on error)
  - Store previous value before edit
  - Validate on focus_exited or text_submitted
  - Revert if validation fails

- [ ] **P2-047**: Display type indicators in column headers
  - Format: "Name (String)", "Health (int)"
  - Use different colors per type
  - Add tooltip with full type info

- [ ] **P2-048**: Test: Edit cells with type enforcement for all basic types
  - Try entering wrong types (text in int, etc.)
  - Verify validation messages appear
  - Verify data is not corrupted
  - Test undo/revert behavior

---

## Phase 5: Class Synchronization (P2-049 to P2-060)

**Goal**: Detect changes to source class files and offer to update table structure accordingly.

**Timeline**: 5-6 days

### Change Detection (P2-049 to P2-053)

- [ ] **P2-049**: Create `class_sync.gd` utility class
  - Methods for comparing class structures
  - Diff generation
  - Update application logic

- [ ] **P2-050**: Monitor source class file modification time
  - Check file modification time on dock visibility
  - Store last known modification time
  - Detect when file changes

- [ ] **P2-051**: Re-parse class when file changes detected
  - Call class_parser.gd automatically
  - Handle parse errors (file might be mid-edit)
  - Cache parsed results

- [ ] **P2-052**: Compare old and new property lists
  - Compare property names
  - Compare property types
  - Compare default values

- [ ] **P2-053**: Identify added, removed, and modified properties
  - Create diff structure: `{added: [], removed: [], modified: []}`
  - Store old and new values for modified properties
  - Prepare for user presentation

### Update Handling (P2-054 to P2-060)

- [ ] **P2-054**: Show confirmation dialog when class changes detected
  - Create custom dialog with diff display
  - Don't auto-update (user consent required)
  - Option to ignore changes

- [ ] **P2-055**: Display diff: added properties (green), removed (red), type changed (yellow)
  - Use RichTextLabel or custom UI
  - Color-code changes
  - Show before/after for modifications

- [ ] **P2-056**: Add "Update Table Structure" button
  - Apply changes to table resource
  - Option for backup/undo
  - Close dialog on completion

- [ ] **P2-057**: Add new columns for added properties (with default values)
  - Insert new columns at appropriate position
  - Fill existing rows with default values
  - Maintain data integrity

- [ ] **P2-058**: Mark removed columns (optional: hide or delete with data backup)
  - Offer choices: delete, hide, or export data
  - Warn about data loss
  - Create backup if deleting

- [ ] **P2-059**: Update column types for modified properties (validate existing data)
  - Check if existing data is compatible with new type
  - Attempt automatic conversion (int→float works, etc.)
  - Warn about incompatible data

- [ ] **P2-060**: Test: Modify source class and sync changes to table
  - Add new property to class
  - Change existing property type
  - Remove property
  - Verify each scenario handles correctly

---

## Phase 6: Advanced Type Support (P2-061 to P2-073)

**Goal**: Extend type support beyond basic primitives to include Godot-specific types.

**Timeline**: 5-6 days

### Vector Types (P2-061 to P2-065)

- [ ] **P2-061**: Parse `Vector2` and `Vector3` type hints
  - Recognize Vector2/Vector3 in type hints
  - Extract default values like `Vector2(1, 2)`
  - Store as structured data

- [ ] **P2-062**: Create custom cell editor for Vector2 (two numeric inputs: x, y)
  - HBoxContainer with two SpinBox controls
  - Labeled "X:" and "Y:"
  - Sync with cell value

- [ ] **P2-063**: Create custom cell editor for Vector3 (three numeric inputs: x, y, z)
  - Similar to Vector2 but with Z component
  - Proper layout and spacing
  - Validate each component

- [ ] **P2-064**: Serialize vectors as strings in resource
  - Format: "(1.0, 2.0)" or "1.0,2.0"
  - Parse back when loading
  - Handle whitespace variations

- [ ] **P2-065**: Test: Create table with Vector2/Vector3 properties
  - Create EnemyData with position: Vector2 and spawn_point: Vector3
  - Verify editors work correctly
  - Test save/load roundtrip

### Color Type (P2-066 to P2-068)

- [ ] **P2-066**: Parse `Color` type hints
  - Recognize Color in type hints
  - Extract default values like `Color.RED` or `Color(1, 0, 0)`
  - Handle named colors

- [ ] **P2-067**: Use ColorPickerButton for color cell editing
  - Native Godot ColorPickerButton
  - Show color preview in cell
  - Store as hex string or RGBA

- [ ] **P2-068**: Test: Create table with Color properties
  - Create ItemData with tint: Color
  - Verify color picker works
  - Test various color formats

### Enum Support (P2-069 to P2-071)

- [ ] **P2-069**: Parse enum declarations in class files
  - Find `enum EnumName { VALUE1, VALUE2 }`
  - Extract enum name and values
  - Associate with properties that use the enum

- [ ] **P2-070**: Create dropdown editor with enum values
  - OptionButton populated with enum values
  - Display enum name in header
  - Store as int or string

- [ ] **P2-071**: Test: Create table with enum properties
  - Create ItemData with `type: ItemType` enum (WEAPON, ARMOR, CONSUMABLE)
  - Verify dropdown shows correct options
  - Test enum value persistence

### Resource References (P2-072 to P2-073)

- [ ] **P2-072**: Parse resource type hints (`: Texture2D`, `: PackedScene`)
  - Recognize built-in resource types
  - Support custom resource classes
  - Handle null defaults

- [ ] **P2-073**: Use EditorResourcePicker for resource selection in cells
  - Native Godot EditorResourcePicker
  - Filter by resource type
  - Show resource path/preview

---

## Phase 7: Bidirectional Class Generation (P2-074 to P2-084)

**Goal**: Allow users to generate GDScript classes from existing tables (reverse direction).

**Timeline**: 4-5 days

### Class Generation Dialog (P2-074 to P2-078)

- [ ] **P2-074**: Create "Generate Class from Table" dialog
  - New dialog scene and script
  - Access from menu: "Tools → Generate Class"
  - Clean, simple UI

- [ ] **P2-075**: Add file save dialog for .gd output path
  - EditorFileDialog with .gd extension
  - Default location: project scripts folder
  - Suggest filename based on table name

- [ ] **P2-076**: Add option for class name input
  - LineEdit for class name
  - Validate identifier rules (no spaces, starts with letter)
  - Auto-suggest from table name

- [ ] **P2-077**: Add checkbox: "Extend Resource" or "Extend RefCounted"
  - RadioButtons or CheckBox
  - Default to Resource for data classes
  - Explain difference in tooltip

- [ ] **P2-078**: Add "Generate" button
  - Validate all inputs
  - Call class_generator utility
  - Show success message with path

### Code Generation (P2-079 to P2-084)

- [ ] **P2-079**: Create `class_generator.gd` utility class
  - Static method: `generate_class(columns, class_name, base_class) -> String`
  - Return formatted GDScript code
  - Handle edge cases

- [ ] **P2-080**: Generate class declaration with `class_name`
  - First line: `class_name ClassName`
  - Second line: `extends Resource` or `extends RefCounted`
  - Add blank line

- [ ] **P2-081**: Generate `@export var` declarations for each column
  - Format: `@export var property_name: Type = default`
  - One per column
  - Proper indentation

- [ ] **P2-082**: Include type hints and default values
  - Use column type to determine GDScript type
  - Include default from column definition
  - Handle null/empty defaults

- [ ] **P2-083**: Write formatted code to .gd file
  - Use FileAccess to write
  - Ensure proper line endings
  - Handle write errors

- [ ] **P2-084**: Test: Generate class from table, verify syntax is valid
  - Create table with mixed types
  - Generate class
  - Open in script editor
  - Verify no syntax errors
  - Try using the class in a test script

---

## Phase 8: Typed Array & Helper Methods (P2-085 to P2-093)

**Goal**: Generate typed array wrappers and helper methods for convenient data access in game code.

**Timeline**: 4-5 days

### Runtime Data Access (P2-085 to P2-089)

- [ ] **P2-085**: Add `get_row_data(row_name: String) -> Dictionary` to ClassTableResource
  - Dictionary-based access to row data
  - Return all column values for a row
  - Return empty dict if row not found

- [ ] **P2-086**: Add `get_row_as_resource(row_name: String) -> Resource` method
  - Instantiate typed resource (e.g., EnemyData)
  - Populate properties from table row
  - Return typed instance with full autocomplete support
  - Cache instances for performance

- [ ] **P2-087**: Add `get_all_as_array() -> Array[Resource]` method
  - Return all rows as typed resource instances
  - Array type matches source class (Array[EnemyData])
  - Useful for iteration and batch operations

- [ ] **P2-088**: Add `export_row_resources(output_dir: String)` method
  - Generate individual .tres files per row
  - Filename: row_name.tres (e.g., goblin.tres)
  - Each file is a typed resource instance
  - Can be directly referenced with @export

- [ ] **P2-089**: Test: All runtime access patterns
  - Test dictionary access
  - Test typed resource access
  - Test array iteration
  - Test exported individual resources
  - Verify type safety and performance

### Array Wrapper Generation (Optional - P2-090 to P2-091)

- [ ] **P2-090**: Generate typed Array wrapper class (optional feature)
  - Create class like `EnemyDataCollection extends Resource`
  - Contains `var enemies: Array[EnemyData] = []`
  - Auto-populate from table resource

- [ ] **P2-091**: Generate query helper methods
  - `find_by_id(id: int) -> EnemyData`
  - `find_by_name(name: String) -> EnemyData`
  - `filter_by(predicate: Callable) -> Array[EnemyData]`
  - `get_random() -> EnemyData`

### Documentation & Examples (P2-092 to P2-093)

- [ ] **P2-092**: Create example game scripts showing all usage patterns
  - Example 1: Dictionary-based access
  - Example 2: Typed resource access
  - Example 3: Individual exported resources
  - Example 4: Batch operations with get_all_as_array()

- [ ] **P2-093**: Document best practices for each usage pattern
  - When to use dictionary vs typed resource
  - Performance considerations
  - Memory usage with caching
  - Workflow recommendations

---

## Phase 9: CSV Export/Import with Types (P2-094 to P2-103)

**Goal**: Export and import CSV files with type metadata for external editing.

**Timeline**: 3-4 days

### CSV Export (P2-094 to P2-098)

- [ ] **P2-094**: Copy `csv_export_dialog.gd` from Implementation 1
  - Duplicate file to class_table folder
  - Update references
  - Keep basic structure

- [ ] **P2-095**: Add type information row to CSV
  - First line: `#TYPES:int,string,float,bool`
  - Second line: column names
  - Third+ lines: data

- [ ] **P2-096**: Format: `#TYPE:int,string,float,bool` as first line
  - Use comma separator
  - Escape special characters
  - Handle complex types (Vector2, etc.)

- [ ] **P2-097**: Export data rows with proper type serialization
  - Vectors as "x,y" or "(x,y)"
  - Colors as hex "#RRGGBB"
  - Enums as strings
  - Bools as true/false

- [ ] **P2-098**: Test: Export typed table to CSV and verify format
  - Export ItemData table
  - Open in text editor
  - Verify type line is correct
  - Verify data is readable

### CSV Import (P2-099 to P2-103)

- [ ] **P2-099**: Copy `csv_import_dialog.gd` from Implementation 1
  - Duplicate file to class_table folder
  - Update references
  - Prepare for type parsing

- [ ] **P2-100**: Parse type information from CSV header
  - Read first line
  - Check for #TYPES: prefix
  - Extract type array

- [ ] **P2-101**: Validate imported data against declared types
  - Check each cell against column type
  - Use type_validator.gd
  - Collect all errors

- [ ] **P2-102**: Show validation errors for type mismatches
  - List all errors in dialog
  - Show row/column location
  - Option to continue or cancel

- [ ] **P2-103**: Test: Import CSV with type info, verify data integrity
  - Export table to CSV
  - Modify in Excel/text editor
  - Import back
  - Verify data matches and types are enforced

---

## Phase 10: UI Polish & Workflow (P2-104 to P2-112)

**Goal**: Improve user experience with better UI feedback and workflow enhancements.

**Timeline**: 3-4 days

### Visual Indicators (P2-104 to P2-108)

- [ ] **P2-104**: Add icon to show table is linked to a class (chain icon in header)
  - Add TextureRect with chain/link icon
  - Position in toolbar or status area
  - Tooltip: "Linked to: path/to/class.gd"

- [ ] **P2-105**: Highlight columns with type colors
  - int = blue tint
  - string = green tint
  - float = purple tint
  - bool = orange tint
  - Subtle background color

- [ ] **P2-106**: Show "Class Modified" warning banner when source class changes
  - Yellow/orange banner at top
  - Message: "Source class has been modified. Click to sync."
  - Clickable to open sync dialog

- [ ] **P2-107**: Add tooltip to column headers showing full type info
  - Hover over header
  - Show: "name (Type) = default"
  - Include additional metadata

- [ ] **P2-108**: Mark read-only columns (if any) with lock icon
  - Small lock icon in header
  - Prevent editing
  - Tooltip explanation

### Menu Options (P2-109 to P2-112)

- [ ] **P2-109**: Add "Sync with Class" menu option
  - In dock toolbar menu
  - Manually trigger sync check
  - Shortcut: Ctrl+Shift+S

- [ ] **P2-110**: Add "Generate Class from Table" menu option
  - In dock toolbar menu
  - Open generation dialog
  - Available even without source class

- [ ] **P2-111**: Add "View Source Class" button (opens .gd file in script editor)
  - Only visible when linked to class
  - Use EditorInterface.edit_script()
  - Handle file not found

- [ ] **P2-112**: Add "Unlink from Class" option (convert to manual spreadsheet)
  - Confirmation dialog
  - Clear source_class_path
  - Enable manual column/row editing
  - One-way operation (warn user)

### Custom Export Property Investigation (P2-112.1 to P2-112.3)

**Goal**: Investigate feasibility of custom `@export` annotations for table row selection in inspector.

- [ ] **P2-112.1**: Research Godot's EditorInspectorPlugin and EditorProperty APIs
  - Study how to create custom property editors
  - Investigate `_parse_property()` and `_parse_group()`
  - Check if we can access other script properties (for table reference)
  - Document limitations and requirements

- [ ] **P2-112.2**: Create proof-of-concept for custom export annotation
  - Attempt: `@export_table_row(table_property_name) var row_id: String`
  - Create EditorInspectorPlugin to detect this pattern
  - Create EditorProperty with dropdown populated from table
  - Test if it's viable or too complex for current scope

- [ ] **P2-112.3**: Document findings and decide on implementation
  - If viable: Add to Phase 4 (Polish) as P4-027 to P4-030
  - If too complex: Document as "Future Enhancement"
  - Recommend workaround: Use enum or script constant for now
  - Update examples with recommended pattern

---

## Phase 11: Documentation & Examples (P2-113 to P2-120)

**Goal**: Create comprehensive documentation and example files for users.

**Timeline**: 3-4 days

### Example Classes (P2-113 to P2-116)

- [ ] **P2-113**: Create `examples/ItemData.gd` with typed properties
  ```gdscript
  class_name ItemData
  extends Resource

  @export var id: int = 0
  @export var name: String = ""
  @export var damage: int = 0
  @export var cost: int = 0
  @export var stackable: bool = false
  ```

- [ ] **P2-114**: Create `examples/EnemyData.gd` with advanced types
  ```gdscript
  class_name EnemyData
  extends Resource

  @export var name: String = ""
  @export var health: int = 100
  @export var position: Vector2 = Vector2.ZERO
  @export var tint: Color = Color.WHITE
  ```

- [ ] **P2-115**: Create `examples/DialogueEntry.gd` with enum support
  ```gdscript
  class_name DialogueEntry
  extends Resource

  enum SpeakerType { PLAYER, NPC, NARRATOR }

  @export var speaker: SpeakerType = SpeakerType.NARRATOR
  @export var text: String = ""
  @export var next_id: int = -1
  ```

- [ ] **P2-116**: Generate example tables from these classes
  - Create table resources
  - Populate with sample data
  - Save in examples/ folder

### Documentation (P2-117 to P2-120)

- [ ] **P2-117**: Write `docs/CLASS_TABLE_GUIDE.md` with workflow documentation
  - Introduction to class-based tables
  - Step-by-step tutorial
  - Screenshots (if possible)
  - Common workflows

- [ ] **P2-118**: Document type mapping
  - Table: GDScript Type → Internal Type → CSV Format
  - Explain each conversion
  - Note limitations

- [ ] **P2-119**: Add best practices guide
  - When to use class tables vs manual tables
  - How to structure data classes
  - Performance considerations
  - Versioning strategies

- [ ] **P2-120**: Create migration guide for converting Implementation 1 tables
  - How to generate class from existing table
  - How to convert data
  - What to watch out for

---

## Phase 12: Testing & Refinement (P2-121 to P2-128)

**Goal**: Thorough testing and bug fixes.

**Timeline**: 4-5 days

### Core Functionality Tests (P2-121 to P2-124)

- [ ] **P2-121**: Test class parsing with 10+ different class structures
  - Simple classes (2-3 properties)
  - Complex classes (10+ properties)
  - Classes with all basic types
  - Classes with advanced types
  - Classes with enums
  - Classes with multiple extends
  - Inner classes
  - Classes with functions (should ignore)
  - Classes with comments
  - Classes with annotations

- [ ] **P2-122**: Test table generation from classes with all supported types
  - Generate table from each test class
  - Verify column structure
  - Verify default values
  - Verify type enforcement

- [ ] **P2-123**: Test type enforcement during editing
  - Try entering text in int column
  - Try entering int in string column
  - Try invalid vectors
  - Try invalid colors
  - Verify validation messages
  - Verify data integrity maintained

- [ ] **P2-124**: Test class synchronization with various change scenarios
  - Add property
  - Remove property
  - Change property type
  - Change property default
  - Rename property
  - Change property order
  - Multiple changes at once

### Edge Cases (P2-125 to P2-128)

- [ ] **P2-125**: Test with classes that have no exported properties
  - Should show warning
  - Should prevent table creation
  - Suggest adding @export

- [ ] **P2-126**: Test with invalid class files
  - Syntax errors
  - Missing extends
  - Empty files
  - Non-GDScript files
  - Should show meaningful errors

- [ ] **P2-127**: Test with class files that get deleted after table creation
  - Delete source class
  - Open table
  - Should show warning
  - Should still allow editing
  - Should prevent sync

- [ ] **P2-128**: Test CSV import/export roundtrip with complex types
  - Export table with Vector2, Color, enums
  - Modify CSV externally
  - Import back
  - Verify data integrity
  - Test error handling

---

## Summary

**Total Tasks**: 128 tasks organized into 12 phases

**Estimated Timeline**: 5-6 weeks (40-45 days)

### Weekly Breakdown:
- **Week 1**: Phase 1-2 (Setup & Parser) - Foundation work
- **Week 2**: Phase 3-4 (Generation & Validation) - Core functionality
- **Week 3**: Phase 5-6 (Sync & Advanced Types) - Enhanced features
- **Week 4**: Phase 7-8 (Bidirectional & Helpers) - Developer tools
- **Week 5**: Phase 9-10 (CSV & Polish) - User experience
- **Week 6**: Phase 11-12 (Docs & Testing) - Finalization

### Phase Dependencies:
```
Phase 1 (Foundation)
    ↓
Phase 2 (Parser)
    ↓
Phase 3 (Generation) ←─────┐
    ↓                       │
Phase 4 (Type Safety)      │
    ↓           ↓          │
Phase 5        Phase 6     │
(Sync)    (Advanced Types) │
    ↓           ↓          │
Phase 7 (Bidirectional) ───┘
    ↓
Phase 8 (Helpers)
    ↓
Phase 9 (CSV)
    ↓
Phase 10 (UI Polish)
    ↓
Phase 11 (Docs) → Phase 12 (Testing)
```

### Key Milestones:
1. **M1**: Basic infrastructure copied and adapted (P2-012)
2. **M2**: Class parser working for basic types (P2-025)
3. **M3**: First table generated from class (P2-038)
4. **M4**: Type-safe editing functional (P2-048)
5. **M5**: Class sync working (P2-060)
6. **M6**: All types supported (P2-073)
7. **M7**: Bidirectional generation working (P2-084)
8. **M8**: Helper methods generated (P2-093)
9. **M9**: CSV with types working (P2-103)
10. **M10**: UI polished (P2-112)
11. **M11**: Documentation complete (P2-120)
12. **M12**: All tests passing (P2-128)

### Success Criteria:
- [ ] Can parse any valid GDScript class with @export variables
- [ ] Can generate table from class automatically
- [ ] Type enforcement prevents invalid data entry
- [ ] Class changes are detected and can be synced
- [ ] All Godot basic types are supported
- [ ] Can generate GDScript class from table
- [ ] Helper methods make data access convenient
- [ ] CSV export/import preserves type information
- [ ] UI is intuitive and provides good feedback
- [ ] Documentation is clear and comprehensive
- [ ] All edge cases are handled gracefully

---

**Last Updated**: October 16, 2025
