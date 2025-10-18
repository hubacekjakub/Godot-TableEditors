# Godot Sheet Editor - Development Plan

This document outlines the development roadmap for the Godot Sheet Editor project. The project is divided into **three separate standalone plugins** for academic purposes, each demonstrating a different approach to data table editing in Godot.

> **Note**: Each task has a unique ID (e.g., `P1-001`) for easy reference in discussions and commits.

---

## Overview: Three Independent Plugins

This project explores three distinct ways to use a data table editor in Godot, implemented as **completely independent, installable plugins** that can be enabled/disabled separately:

1. **Plugin 1: Data Spreadsheet** (aka "Sheet Editor" / "Spreadsheet Editor")
   - A standalone spreadsheet-like editor for creating arbitrary data tables with CSV support
   - Alternative names: *Data Spreadsheet*, *Simple Sheet Editor*, *Table Creator*

2. **Plugin 2: Class Table Editor** (aka "Typed Table Editor" / "Class Schema Editor")
   - Automatically generate and maintain data tables based on GDScript class definitions with type safety
   - Alternative names: *Typed Data Editor*, *Class-Based Tables*, *Schema Editor*

3. **Plugin 3: Resource Collection Editor** (aka "Bulk Resource Editor" / "Resource Browser")
   - Edit multiple resource files of the same type in a unified table view
   - Alternative names: *Resource Batch Editor*, *Multi-Resource Editor*, *Resource Collection Manager*

Each plugin will be **completely independent, fully functional, and installable separately** in `addons/`. They will:
- Have their own `plugin.cfg` file
- Have their own folder structure
- Have zero dependencies on each other
- Can be enabled/disabled independently in Godot's Plugin Manager
- Maintain their own complete codebase (no shared code between plugins)

---

## Plugin Architecture

Each plugin is **completely self-contained** with its own folder and configuration:

```
addons/
├── sheet_editor/                          # Plugin 1: Data Spreadsheet
│   ├── plugin.cfg                         # Entry point for this plugin
│   ├── spreadsheet_plugin.gd              # Main EditorPlugin class
│   ├── spreadsheet_dock.gd                # Main UI dock
│   ├── spreadsheet_dock.tscn              # Dock scene
│   ├── spreadsheet_resource.gd            # Sheet resource class
│   ├── create_table_dialog.gd             # Create new sheet dialog
│   ├── create_table_dialog.tscn           # Dialog scene
│   ├── csv_export_dialog.gd               # CSV export functionality
│   └── csv_import_dialog.gd               # CSV import functionality
│
├── class_table_editor/                    # Plugin 2: Class Table Editor
│   ├── plugin.cfg                         # Entry point for this plugin
│   ├── class_table_plugin.gd              # Main EditorPlugin class
│   ├── class_table_dock.gd                # Main UI dock (adapted from P1)
│   ├── class_table_dock.tscn              # Dock scene (adapted from P1)
│   ├── class_table_resource.gd            # Typed sheet resource class
│   ├── class_select_dialog.gd             # Select class to edit dialog
│   ├── class_select_dialog.tscn           # Dialog scene
│   ├── class_parser.gd                    # Parse GDScript classes
│   ├── class_sync.gd                      # Sync class ↔ table
│   ├── class_generator.gd                 # Generate classes from tables
│   ├── csv_export_dialog.gd               # CSV export with type info
│   └── csv_import_dialog.gd               # CSV import with validation
│
└── resource_collection_editor/            # Plugin 3: Resource Collection Editor
    ├── plugin.cfg                         # Entry point for this plugin
    ├── resource_editor_plugin.gd          # Main EditorPlugin class
    ├── resource_editor_dock.gd            # Main UI dock (adapted from P1)
    ├── resource_editor_dock.tscn          # Dock scene (adapted from P1)
    ├── open_collection_dialog.gd          # Open folder dialog
    ├── open_collection_dialog.tscn        # Dialog scene
    ├── resource_scanner.gd                # Scan folders for resources
    ├── resource_loader.gd                 # Load multiple resources
    └── resource_writer.gd                 # Save changes to resources
```

**Key Points:**
- Each plugin is in its own top-level folder within `addons/`
- Each plugin has its own independent `plugin.cfg`
- No shared code between plugins (all UI/logic is duplicated)
- Plugins can be enabled/disabled independently in Godot's Plugin Manager
- Zero runtime dependencies between plugins

---

## Plugin 1: Data Spreadsheet (✅ COMPLETE)

**Use Case**: Creating game data tables (item lists, enemy stats, dialogue trees) without predefined schemas. Users manually define columns and rows, then export to CSV or save as Godot resources.

**Key Features**:
- Manual column/row creation and editing
- CSV export/import for external tools integration
- Save as Godot resources (.tres files)
- No code or predefined schema required

**Status**: ✅ Core functionality complete, CSV export/import complete, structure flattened and verified working.

**Note**: All code in this implementation is self-contained and flat in `addons/sheet_editor/` and will not be shared with other implementations. This includes dialogs, dock UI, and resource classes.

### Tasks

- [x] **Plugin Infrastructure**
  - [x] `P1-001` Set up plugin structure and configuration
  - [x] `P1-002` Create custom editor dock
  - [x] `P1-003` Implement basic UI layout with menu bar
  - [x] `P1-003.5` Add "New Sheet" functionality for creating blank sheets

- [x] **Grid Implementation**
  - [x] `P1-004` Create editable grid/table control
  - [x] `P1-005` Implement cell editing functionality
  - [x] `P1-006` Add cell selection and navigation

- [x] **Column Management**
  - [x] `P1-007` Add "Add Column" functionality
  - [x] `P1-008` Implement column naming
  - [x] `P1-009` Add column deletion

- [x] **Row Management**
  - [x] `P1-012` Add "Add Row" functionality
  - [x] `P1-013` Implement row naming (editable row headers shown in editor)
  - [x] `P1-014` Implement row deletion

- [x] **Data Persistence**
  - [x] `P1-016` Create custom Resource class for data tables (Sheet.gd)
  - [x] `P1-017` Implement save functionality (using ResourceSaver)
  - [x] `P1-018` Implement load functionality (using EditorInterface)

- [x] **CSV Export/Import** (Minimal Implementation)
  - [x] `P1-019` Implement simple CSV export dialog with file path selection
  - [x] `P1-020` Export table data to CSV (comma-separated, with header row and row names)
  - [x] `P1-021` Implement simple CSV import dialog with file path selection
  - [x] `P1-022` Import CSV data and populate table (basic parsing, supports row names)

- [x] **Refactoring for Multi-Implementation Support**
  - [x] `P1-023` Move current files to `spreadsheet/` folder
  - [x] `P1-024` Rename files with `spreadsheet_` prefix
  - [x] `P1-025` Update plugin.cfg and plugin entry point for mode switching
  - [x] `P1-026` Test Implementation 1 works independently in new structure

---

## Plugin 2: Class Table Editor (✅ SETUP COMPLETE - Ready for Enhancement)

**Use Case**: Type-safe data management where the table structure mirrors a GDScript class. For example, an `ItemData` class with properties like `name: String`, `damage: int`, `icon: Texture2D` generates a table with corresponding columns. Changes to the class can update the table structure.

**Key Features**:
- Parse GDScript classes and extract typed properties
- Generate table columns from class properties
- Bidirectional sync: class ↔ table
- Type enforcement based on GDScript types
- CSV export/import with type preservation
- Completely separate codebase from Plugin 1

**Status**: ✅ Infrastructure setup complete and verified working. Ready for class parsing and type-safety enhancements.

**Note**: This plugin has its own dialogs, dock UI, and all necessary code duplicated and adapted from Plugin 1. No code sharing between plugins to maintain independence.

### Tasks

- [x] **Plugin Infrastructure & Setup** (M2-001 to M2-009)
  - [x] `M2-001` Create `addons/class_table_editor/` folder
  - [x] `M2-002` Create `plugin.cfg` for Class Table Editor
  - [x] `M2-003` Copy and adapt all Plugin 1 files to Plugin 2 folder
  - [x] `M2-004` Rename all copied files with `class_table_` prefix
  - [x] `M2-005` Update all class references (SpreadsheetResource → ClassTableResource)
  - [x] `M2-006` Update plugin entry point in `plugin.cfg`
  - [x] `M2-007` Test Plugin 2 loads independently
  - [x] `M2-008` Remove Plugin 2 code from Plugin 1 (clean separation)
  - [x] `M2-009` Test all 3 plugins work independently

- [ ] **Core Class Functionality** (P2-001 to P2-008)
  - [ ] `P2-001` Create ClassTableResource class extending ClassTableResource
  - [ ] `P2-002` Add type information storage to class table resource
  - [ ] `P2-003` Implement class name tracking (which class this table represents)
  - [ ] `P2-004` Add property type metadata to columns
  - [ ] `P2-005` Create basic GDScript class parser utility
  - [ ] `P2-006` Parse class properties from .gd files
  - [ ] `P2-007` Extract property names, types, and default values
  - [ ] `P2-008` Create class caching system for performance

- [ ] **Class-to-Table Generation** (P2-009 to P2-018)
  - [ ] `P2-009` Create "Select Class" dialog for choosing classes
  - [ ] `P2-010` Detect GDScript classes in the project
  - [ ] `P2-011` Parse and extract class properties
  - [ ] `P2-012` Auto-generate table columns from class properties
  - [ ] `P2-013` Map property types to column types (String, int, float, bool, Color, Vector2, etc.)
  - [ ] `P2-014` Set initial values from class defaults
  - [ ] `P2-015` Handle custom Resource classes
  - [ ] `P2-016` Handle class inheritance chains
  - [ ] `P2-017` Create new class table instances from selected class
  - [ ] `P2-018` Store class reference in table metadata

- [ ] **Type-Safe Editing** (P2-019 to P2-028)
  - [ ] `P2-019` Implement type validation for cell edits
  - [ ] `P2-020` Create type-specific cell editors (StringEdit, IntSpinBox, FloatSpinBox, etc.)
  - [ ] `P2-021` Validate string values before assignment
  - [ ] `P2-022` Validate numeric types (int, float ranges)
  - [ ] `P2-023` Handle boolean cells with checkboxes
  - [ ] `P2-024` Support Color type with color picker
  - [ ] `P2-025` Support Vector2/Vector3 type editing
  - [ ] `P2-026` Show type validation errors in UI
  - [ ] `P2-027` Prevent invalid data entry
  - [ ] `P2-028` Display type hints in column headers

- [ ] **Class Synchronization** (P2-029 to P2-038)
  - [ ] `P2-029` Detect changes to source class files
  - [ ] `P2-030` Monitor class file modifications
  - [ ] `P2-031` Parse updated class properties
  - [ ] `P2-032` Add new properties to table when class changes
  - [ ] `P2-033` Remove properties from table when class properties deleted
  - [ ] `P2-034` Handle property type changes
  - [ ] `P2-035` Show sync status/warnings in UI
  - [ ] `P2-036` Provide manual "Refresh from Class" button
  - [ ] `P2-037` Handle conflicts when table and class diverge
  - [ ] `P2-038` Create sync resolution UI

- [ ] **Advanced Type Support** (P2-039 to P2-050)
  - [ ] `P2-039` Support Enum types (parse and display enum values)
  - [ ] `P2-040` Support Resource subclass types (with picker)
  - [ ] `P2-041` Support Texture2D, Image, AudioStream types
  - [ ] `P2-042` Support TypedArray types (Array[T])
  - [ ] `P2-043` Support NodePath type
  - [ ] `P2-044` Support StringName type
  - [ ] `P2-045` Support RID type
  - [ ] `P2-046` Support Callable type
  - [ ] `P2-047` Handle optional/nullable types
  - [ ] `P2-048` Show appropriate UI for each type
  - [ ] `P2-049` Create type conversion utilities
  - [ ] `P2-050` Handle type conversion errors gracefully

- [ ] **Bidirectional Class Generation** (P2-051 to P2-062)
  - [ ] `P2-051` Create "Generate Class from Table" feature
  - [ ] `P2-052` Generate GDScript class code from table structure
  - [ ] `P2-053` Create property declarations from table columns
  - [ ] `P2-054` Generate with proper GDScript syntax
  - [ ] `P2-055` Add class documentation/comments
  - [ ] `P2-056` Generate getter/setter methods if desired
  - [ ] `P2-057` Create update option to merge table changes into existing class
  - [ ] `P2-058` Handle manual edits to class (don't overwrite user code)
  - [ ] `P2-059` Create "Save Generated Class" dialog
  - [ ] `P2-060` Write generated class to .gd file
  - [ ] `P2-061` Reload and use newly generated class
  - [ ] `P2-062` Add version tracking for regeneration

- [ ] **CSV Export/Import with Types** (P2-063 to P2-074)
  - [ ] `P2-063` Export table to CSV with type information in header
  - [ ] `P2-064` Include type hints in CSV (e.g., "name:String", "damage:int")
  - [ ] `P2-065` Export default values for reference
  - [ ] `P2-066` Create structured CSV format for type preservation
  - [ ] `P2-067` Import CSV and validate against class types
  - [ ] `P2-068` Convert imported values to correct types
  - [ ] `P2-069` Show validation errors during import
  - [ ] `P2-070` Handle type mismatches with user choices (skip/convert/abort)
  - [ ] `P2-071` Support partial imports (new rows only, update existing, etc.)
  - [ ] `P2-072` Preserve row IDs during import/export
  - [ ] `P2-073` Create import wizard with preview
  - [ ] `P2-074` Add rollback option if import fails

- [ ] **UI/UX Enhancements** (P2-075 to P2-086)
  - [ ] `P2-075` Add "Class Name" display in dock title
  - [ ] `P2-076` Show class file path in status bar
  - [ ] `P2-077` Highlight columns by type (color coding)
  - [ ] `P2-078` Add column type indicators (icons)
  - [ ] `P2-079` Show validation status per column
  - [ ] `P2-080` Create type legend/reference panel
  - [ ] `P2-081` Add keyboard shortcuts for type-specific operations
  - [ ] `P2-082` Implement undo/redo for cell edits
  - [ ] `P2-083` Add cell selection and multi-cell operations
  - [ ] `P2-084` Create data visualization for numeric columns
  - [ ] `P2-085` Add search/filter by type or value
  - [ ] `P2-086` Create sorting with type awareness

- [ ] **Data Validation Rules** (P2-087 to P2-096)
  - [ ] `P2-087` Implement min/max constraints for numeric types
  - [ ] `P2-088` Add pattern matching for string types
  - [ ] `P2-089` Create custom validation rules
  - [ ] `P2-090` Add required field validation
  - [ ] `P2-091` Implement cross-field validation (e.g., health > 0)
  - [ ] `P2-092` Show validation errors inline
  - [ ] `P2-093` Block invalid data save
  - [ ] `P2-094` Create validation rule editor
  - [ ] `P2-095` Export validation rules with class
  - [ ] `P2-096` Add data cleaning/normalization options

- [ ] **Runtime Integration** (P2-097 to P2-104)
  - [ ] `P2-097` Create data loading API for game scripts
  - [ ] `P2-098` Generate typed query helpers
  - [ ] `P2-099` Create type-safe data accessors
  - [ ] `P2-100` Implement filtered data access by property values
  - [ ] `P2-101` Add data iteration with type safety
  - [ ] `P2-102` Create data change notifications
  - [ ] `P2-103` Add runtime validation
  - [ ] `P2-104` Document API usage examples

- [ ] **Documentation & Examples** (P2-105 to P2-110)
  - [ ] `P2-105` Document class-to-table workflow
  - [ ] `P2-106` Create example GDScript classes
  - [ ] `P2-107` Create example tables from classes
  - [ ] `P2-108` Document type system and constraints
  - [ ] `P2-109` Create type mapping reference guide
  - [ ] `P2-110` Provide troubleshooting guide for common issues

---

## Plugin 3: Resource Collection Editor (Planning)

**Use Case**: Managing collections of similar resources. For example, you have 50 `Enemy.tres` files (Goblin.tres, Dragon.tres, etc.), each with properties like `health: int`, `speed: float`, `texture: Texture2D`. The editor displays all enemies in one table, with each row being one enemy file.

**Key Features**:
- Load multiple resource files of the same class
- Display as table: rows = resource files, columns = properties
- Edit properties directly in the table
- Save changes back to individual .tres files
- Add/remove resource files from collection
- Completely separate codebase from other plugins

**Note**: This plugin will have its own complete UI and logic, duplicated and adapted as needed. CSV export/import may be added later but is not a priority for this plugin.

### Tasks

- [ ] **Resource Discovery** (P3-001 to P3-005)
  - [ ] `P3-001` Scan folder for resource files of same type
  - [ ] `P3-002` Detect resource class and properties
  - [ ] `P3-003` Filter resources by selected class type
  - [ ] `P3-004` Handle resources without predefined structure
  - [ ] `P3-005` Support custom Resource classes

- [ ] **Table View Generation** (P3-006 to P3-010)
  - [ ] `P3-006` Create "Open Resource Collection" dialog
  - [ ] `P3-007` Map resource files to table rows
  - [ ] `P3-008` Map resource properties to table columns
  - [ ] `P3-009` Handle different property types in columns
  - [ ] `P3-010` Display resource filename in first column

- [ ] **Editing & Persistence** (P3-011 to P3-015)
  - [ ] `P3-011` Edit property values in table cells
  - [ ] `P3-012` Save changes back to .tres files individually
  - [ ] `P3-013` Validate property types before saving
  - [ ] `P3-014` Add new resource files to collection
  - [ ] `P3-015` Support deleting resource files

- [ ] **Advanced Features** (P3-016 to P3-020)
  - [ ] `P3-016` Filter/search resources by property values
  - [ ] `P3-017` Sort resources by column values
  - [ ] `P3-018` Batch edit properties across multiple resources
  - [ ] `P3-019` Generate new resource instances from template
  - [ ] `P3-020` Duplicate resource files with variations

- [ ] **UI & UX** (P3-021 to P3-024)
  - [ ] `P3-021` Show resource file path in tooltip
  - [ ] `P3-022` Highlight unsaved changes visually
  - [ ] `P3-023` Add "Save All" button to save entire collection
  - [ ] `P3-024` Support drag-and-drop of .tres files

- [ ] **Documentation** (P3-025 to P3-026)
  - [ ] `P3-025` Document resource collection workflow
  - [ ] `P3-026` Provide example resource collections

---

## Implementation 2: GDScript Class Integration

**Approach**: Automatically generate and maintain data tables based on GDScript class definitions.

**Use Case**: Type-safe data management where the table structure mirrors a GDScript class. For example, an `ItemData` class with properties like `name: String`, `damage: int`, `icon: Texture2D` generates a table with corresponding columns. Changes to the class can update the table structure.

**Key Features**:
- Parse GDScript classes and extract typed properties
- Generate table columns from class properties
- Bidirectional sync: class → table and table → class
- Type enforcement based on GDScript types
- CSV export/import with type preservation
- Completely separate codebase from Implementation 1

**Status**: Not started. Will begin with copying Implementation 1 files.

**Note**: This implementation will have its own dialogs, dock UI, and all necessary code duplicated and adapted from Implementation 1. No code sharing between implementations to maintain independence.

---

### 📋 Detailed Plan

**See [PLAN_IMPLEMENTATION_2.md](PLAN_IMPLEMENTATION_2.md) for the complete detailed plan with 128 tasks across 12 phases.**

### Quick Overview of Phases

1. **Phase 1: Foundation & Code Duplication** (P2-001 to P2-012) - Copy and adapt Implementation 1 files
2. **Phase 2: GDScript Class Parser** (P2-013 to P2-025) - Build class parsing functionality
3. **Phase 3: Class-to-Table Generation** (P2-026 to P2-038) - Generate tables from classes
4. **Phase 4: Type-Safe Editing** (P2-039 to P2-048) - Enforce type constraints
5. **Phase 5: Class Synchronization** (P2-049 to P2-060) - Detect and sync class changes
6. **Phase 6: Advanced Type Support** (P2-061 to P2-073) - Vector, Color, Enum, Resource types
7. **Phase 7: Bidirectional Class Generation** (P2-074 to P2-084) - Generate classes from tables
8. **Phase 8: Typed Array & Helper Methods** (P2-085 to P2-093) - Query helpers and wrappers
9. **Phase 9: CSV Export/Import with Types** (P2-094 to P2-103) - Type-aware CSV handling
10. **Phase 10: UI Polish & Workflow** (P2-104 to P2-112) - Enhanced user experience
11. **Phase 11: Documentation & Examples** (P2-113 to P2-120) - Comprehensive docs
12. **Phase 12: Testing & Refinement** (P2-121 to P2-128) - Thorough testing

### Timeline Summary

- **Total Tasks**: 128 (P2-001 to P2-128)
- **Estimated Duration**: 5-6 weeks
- **Key Milestones**:
  - M1: Basic infrastructure copied (P2-012)
  - M2: Class parser working (P2-025)
  - M3: First table generated from class (P2-038)
  - M4: Type-safe editing functional (P2-048)
  - M5: Class sync working (P2-060)
  - M6: All types supported (P2-073)
  - M7: Bidirectional generation (P2-084)
  - M8: Helper methods generated (P2-093)
  - M9: CSV with types (P2-103)
  - M10: UI polished (P2-112)
  - M11: Documentation complete (P2-120)
  - M12: All tests passing (P2-128)

---

## Implementation 3: Resource Collection Editor

**Approach**: Edit multiple resource files of the same type in a unified table view, where each row represents one resource file and each column represents a property.

**Use Case**: Managing collections of similar resources. For example, you have 50 `Enemy.tres` files (Goblin.tres, Dragon.tres, etc.), each with properties like `health: int`, `speed: float`, `texture: Texture2D`. The editor displays all enemies in one table, with each row being one enemy file.

**Key Features**:
- Load multiple resource files of the same class
- Display as table: rows = resource files, columns = properties
- Edit properties directly in the table
- Save changes back to individual .tres files
- Add/remove resource files from collection
- Completely separate codebase from other implementations

**Note**: This implementation will have its own complete UI and logic, duplicated and adapted as needed. CSV export/import may be added later but is not a priority for this implementation.

### Tasks

- [ ] **Resource Discovery** (P3-001 to P3-005)
  - [ ] `P3-001` Scan folder for resource files of same type
  - [ ] `P3-002` Detect resource class and properties
  - [ ] `P3-003` Load multiple resources efficiently
  - [ ] `P3-004` Handle resource dependencies
  - [ ] `P3-005` Support custom Resource classes

- [ ] **Table View Generation** (P3-006 to P3-010)
  - [ ] `P3-006` Create "Open Resource Collection" dialog
  - [ ] `P3-007` Select folder containing resources
  - [ ] `P3-008` Detect common properties across resources
  - [ ] `P3-009` Generate table with row = resource file
  - [ ] `P3-010` Display resource filename in first column

- [ ] **Editing & Persistence** (P3-011 to P3-015)
  - [ ] `P3-011` Edit property values in table cells
  - [ ] `P3-012` Auto-save or manual save per resource
  - [ ] `P3-013` Handle property type validation
  - [ ] `P3-014` Support adding new resource files
  - [ ] `P3-015` Support deleting resource files

- [ ] **Advanced Features** (P3-016 to P3-020)
  - [ ] `P3-016` Filter/search resources by property values
  - [ ] `P3-017` Sort resources by any column
  - [ ] `P3-018` Handle nested properties (sub-resources)
  - [ ] `P3-019` Bulk edit multiple resources
  - [ ] `P3-020` Duplicate resource files with variations

- [ ] **UI & UX** (P3-021 to P3-024)
  - [ ] `P3-021` Show resource file path in tooltip
  - [ ] `P3-022` Highlight unsaved changes
  - [ ] `P3-023` Add "Refresh" to reload resources
  - [ ] `P3-024` Support drag-and-drop of .tres files

- [ ] **Documentation** (P3-025 to P3-026)
  - [ ] `P3-025` Document resource collection workflow
  - [ ] `P3-026` Provide example resource collections

---

## Summary: Plugin Restructuring Strategy

### Current State
- **Plugin 1 (Data Spreadsheet)**: Located in `addons/sheet_editor/` (flat structure) ✅ Complete
- **Plugin 2 (Class Table Editor)**: Currently nested in `addons/sheet_editor/class_table/` - **Needs separation**
- **Plugin 3 (Resource Collection Editor)**: Not yet started

### Next Steps: Migration Phase

**Phase 0: Separate Plugin 2 (Class Table Editor)**
1. Create new top-level folder: `addons/class_table_editor/`
2. Move all files from `addons/sheet_editor/class_table/` to new location
3. Create independent `plugin.cfg` for class table editor
4. Remove Plugin 2 code from Plugin 1 to ensure zero dependencies
5. Update main plugin entry point to only handle Plugin 1
6. Test both plugins work independently in Godot Plugin Manager

**Phase 1: Create Plugin 3 (Resource Collection Editor)**
1. Create new top-level folder: `addons/resource_collection_editor/`
2. Copy and adapt UI structures from Plugin 1
3. Implement resource discovery and loading
4. Build table view for resource collections
5. Test Plugin 3 works independently

### Final Structure
```
addons/
├── sheet_editor/                    # Plugin 1: Data Spreadsheet
├── class_table_editor/              # Plugin 2: Class Table Editor
└── resource_collection_editor/      # Plugin 3: Resource Collection Editor
```

Each plugin will:
- Have independent `plugin.cfg` files
- Appear separately in Godot's Plugin Manager
- Be enabled/disabled independently
- Have zero runtime dependencies on each other
- Maintain complete and self-contained codebases
  - [ ] `P4-001` Add keyboard shortcuts
  - [ ] `P4-002` Implement undo/redo system
  - [ ] `P4-003` Add search and filter functionality
  - [ ] `P4-004` Improve cell editing with specialized editors
  - [ ] `P4-005` Add data validation rules
  - [ ] `P4-006` Add auto-save option

- [ ] **Advanced Features**
  - [ ] `P4-007` Support for formulas and calculated columns
  - [ ] `P4-008` Add data sorting and filtering
  - [ ] `P4-009` Implement cell formatting (colors, fonts)
  - [ ] `P4-010` Add support for referenced data (foreign keys)
  - [ ] `P4-011` Create data visualization tools
  - [ ] `P4-012` Support column reordering (drag & drop)
  - [ ] `P4-013` Add column type selection (String, Int, Float, Bool)
  - [ ] `P4-014` Support row reordering (drag & drop)
  - [ ] `P4-015` Add row selection

- [ ] **Documentation & Examples**
  - [ ] `P4-016` Write usage guide for all three implementations
  - [ ] `P4-017` Add code examples for loading data in scripts
  - [ ] `P4-018` Create example resource files for each implementation
  - [ ] `P4-019` Create video tutorials (optional)

- [ ] **Performance**
  - [ ] `P4-020` Optimize for large datasets (1000+ rows)
  - [ ] `P4-021` Implement virtual scrolling
  - [ ] `P4-022` Add lazy loading for large tables

- [ ] **Integration**
  - [ ] `P4-023` Add API for runtime data manipulation
  - [ ] `P4-024` Create helper functions for common queries
  - [ ] `P4-025` Add JSON export/import
  - [ ] `P4-026` Support for database connections (SQLite)

---

## Implementation Architecture

To maintain separation between the three implementations:

1. **Shared Core**: Minimal common utilities (e.g., basic grid helpers) in `core/` folder
2. **Independent Implementations**: Each implementation has its own complete codebase
3. **No Code Sharing Between Implementations**: Dialogs, docks, and logic are duplicated and adapted per implementation
4. **Academic Independence**: Each implementation can be studied, modified, or removed without affecting others
5. **Folder Structure**:
   ```
   addons/sheet_editor/
   ├── core/                         # Minimal shared utilities (optional)
   │   ├── grid_helpers.gd          # Basic grid math/helpers
   │   └── common_types.gd          # Shared enums/constants
   │
   ├── spreadsheet/                      # Implementation 1: Complete & self-contained
   │   ├── spreadsheet_plugin.gd        # Plugin entry point
   │   ├── spreadsheet_dock.gd          # Main dock UI
   │   ├── spreadsheet_dock.tscn        # Dock scene
   │   ├── spreadsheet_resource.gd      # Sheet resource class
   │   ├── create_table_dialog.gd       # Create table dialog
   │   ├── create_table_dialog.tscn     # Dialog scene
   │   ├── csv_export_dialog.gd         # Simple CSV export dialog
   │   └── csv_import_dialog.gd         # Simple CSV import dialog
   │
   │   # Current files (to be moved/renamed):
   │   # - sheet_editor_plugin.gd → spreadsheet_plugin.gd
   │   # - sheet_editor_dock.gd → spreadsheet_dock.gd
   │   # - sheet_editor_dock.tscn → spreadsheet_dock.tscn
   │   # - sheet.gd → spreadsheet_resource.gd
   │   # - create_table_dialog.gd (keep name)
   │   # - create_table_dialog.tscn (keep name)
   │
   ├── class_table/                  # Implementation 2: Complete & self-contained
   │   ├── class_table_dock.gd      # Main dock UI (adapted from spreadsheet)
   │   ├── class_table_dock.tscn    # Dock scene
   │   ├── class_table_sheet.gd     # Typed sheet resource
   │   ├── create_dialog.gd         # Create/import class dialog (duplicate)
   │   ├── create_dialog.tscn       # Dialog scene (duplicate)
   │   ├── class_parser.gd          # Parse GDScript class files
   │   ├── class_sync.gd            # Synchronize class ↔ table
   │   ├── class_generator.gd       # Generate classes from tables
   │   ├── csv_export_dialog.gd     # CSV export with type info (duplicate)
   │   └── csv_import_dialog.gd     # CSV import with validation (duplicate)
   │
   ├── resource_editor/              # Implementation 3: Complete & self-contained
   │   ├── resource_editor_dock.gd  # Main dock UI (adapted from spreadsheet)
   │   ├── resource_editor_dock.tscn # Dock scene
   │   ├── open_collection_dialog.gd # Open folder dialog (adapted)
   │   ├── open_collection_dialog.tscn # Dialog scene
   │   ├── resource_scanner.gd      # Scan folders for resources
   │   ├── resource_loader.gd       # Load multiple resources
   │   └── resource_saver.gd        # Save resources back to files
   │
   ├── plugin.cfg                    # Main plugin configuration
   └── sheet_editor_plugin.gd        # Main plugin entry point (mode switcher)
   ```

**Why Duplicate Code?**
- Each implementation remains fully functional independently
- Easy to compare different approaches side-by-side
- Can delete any implementation without breaking others
- Academic clarity: each folder is a complete, self-contained solution
- Prevents coupling and hidden dependencies

---

## Timeline Estimates

- **Implementation 1 (Spreadsheet)**: 4-5 weeks
  - Core complete ✅ (4 weeks)
  - Remaining: Minimal CSV export/import (0.5-1 week)
- **Implementation 2 (Class Table)**: 5-6 weeks
  - Includes: Complete UI duplication, class parsing, sync, minimal CSV with types
- **Implementation 3 (Resource Editor)**: 3-4 weeks
  - Includes: Complete UI duplication, resource scanning, bulk editing
- **Phase 4 (Polish)**: Ongoing

*Note: Timeline estimates are approximate and may vary based on complexity and testing requirements.*

**Code Duplication Impact**: Each implementation will duplicate ~60-70% of UI code from Implementation 1, then diverge for specific functionality. This is intentional for academic independence.

**CSV Simplification**: CSV functionality is kept minimal (comma-separated, basic parsing) to focus on demonstrating the core concepts rather than edge case handling.

---

## Contributing

See individual implementation tasks for areas where contributions are welcome. Please open an issue to discuss major changes before implementing them.

---

**Last Updated**: October 15, 2025
