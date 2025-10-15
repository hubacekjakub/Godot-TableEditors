# Godot Sheet Editor - Development Plan

This document outlines the development roadmap for the Godot Sheet Editor plugin. The project is divided into **three separate implementations** for academic purposes, each demonstrating a different approach to data table editing in Godot.

> **Note**: Each task has a unique ID (e.g., `P1-001`) for easy reference in discussions and commits.

---

## Overview: Three Implementation Approaches

This plugin explores three distinct ways to use a data table editor in Godot:

1. **Implementation 1: Excel-Style Table Editor** - A standalone spreadsheet-like editor for creating arbitrary data tables with CSV support
2. **Implementation 2: GDScript Class Integration** - Generate tables automatically from GDScript class definitions with type safety
3. **Implementation 3: Resource Collection Editor** - Edit multiple resource files of the same type in a unified table view

Each implementation will be **independently functional** and can be kept or removed separately. Code may be copied and adapted between implementations, but they remain distinct plugins/modes.

---

## Implementation 1: Excel-Style Table Editor ✅ (In Progress)

**Approach**: A standalone spreadsheet-like editor for creating arbitrary data tables, similar to Excel or Google Sheets.

**Use Case**: Creating game data tables (item lists, enemy stats, dialogue trees) without predefined schemas. Users manually define columns and rows, then export to CSV or save as Godot resources.

**Key Features**:
- Manual column/row creation and editing
- CSV export/import for external tools integration
- Save as Godot resources (.tres files)
- No code or predefined schema required

**Status**: Core functionality complete, CSV export/import pending.

**Note**: All code in this implementation is self-contained in the `spreadsheet/` folder and will not be shared with other implementations. This includes dialogs, dock UI, and resource classes.

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
  - [x] `P1-013` Implement row naming
  - [x] `P1-014` Implement row deletion

- [x] **Data Persistence**
  - [x] `P1-016` Create custom Resource class for data tables (Sheet.gd)
  - [x] `P1-017` Implement save functionality (using ResourceSaver)
  - [x] `P1-018` Implement load functionality (using EditorInterface)

- [x] **CSV Export/Import** (Minimal Implementation)
  - [x] `P1-019` Implement simple CSV export dialog with file path selection
  - [x] `P1-020` Export table data to CSV (comma-separated, with header row)
  - [x] `P1-021` Implement simple CSV import dialog with file path selection
  - [x] `P1-022` Import CSV data and populate table (basic parsing)

- [x] **Refactoring for Multi-Implementation Support**
  - [x] `P1-023` Move current files to `spreadsheet/` folder
  - [x] `P1-024` Rename files with `spreadsheet_` prefix
  - [x] `P1-025` Update plugin.cfg and plugin entry point for mode switching
  - [x] `P1-026` Test Implementation 1 works independently in new structure

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

**Note**: This implementation will have its own dialogs, dock UI, and all necessary code duplicated and adapted from Implementation 1. No code sharing between implementations to maintain independence.

### Tasks

- [ ] **Class Analysis** (P2-001 to P2-005)
  - [ ] `P2-001` Parse GDScript class files
  - [ ] `P2-002` Extract class properties and their types
  - [ ] `P2-003` Support for `int`, `float`, and `bool` types
  - [ ] `P2-004` Handle type hints and default values
  - [ ] `P2-005` Support exported variables (@export)

- [ ] **Table Generation** (P2-006 to P2-010)
  - [ ] `P2-006` Create "Generate from Class" dialog
  - [ ] `P2-007` Allow class file selection
  - [ ] `P2-008` Display detected properties and types
  - [ ] `P2-009` Generate table structure from class
  - [ ] `P2-010` Map GDScript types to column types

- [ ] **Class Synchronization** (P2-011 to P2-014)
  - [ ] `P2-011` Detect when source class changes
  - [ ] `P2-012` Offer to update table structure
  - [ ] `P2-013` Handle added/removed properties
  - [ ] `P2-014` Preserve existing data when possible

- [ ] **Bidirectional Support** (P2-015 to P2-017)
  - [ ] `P2-015` Generate GDScript class from existing table
  - [ ] `P2-016` Create typed array wrapper classes
  - [ ] `P2-017` Add helper methods for data access

- [ ] **Advanced Type Support** (P2-018 to P2-022)
  - [ ] `P2-018` Add support for `String` type
  - [ ] `P2-019` Add support for `Vector2` and `Vector3`
  - [ ] `P2-020` Add support for `Color`
  - [ ] `P2-021` Add support for enums
  - [ ] `P2-022` Add support for resource references

- [ ] **CSV Export/Import** (P2-023 to P2-026)
  - [ ] `P2-023` Implement CSV export with type information in header
  - [ ] `P2-024` Export typed data to CSV (comma-separated)
  - [ ] `P2-025` Implement CSV import with type validation
  - [ ] `P2-026` Import CSV and validate against class schema

- [ ] **Documentation** (P2-027 to P2-030)
  - [ ] `P2-027` Document class-to-table workflow
  - [ ] `P2-028` Provide example classes
  - [ ] `P2-029` Add best practices guide
  - [ ] `P2-030` Create migration guide from manual tables

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

## Phase 4: Polish & Advanced Features (Cross-Implementation)

**Goal**: Enhance user experience and add power-user features that can apply to any implementation.

### Potential Tasks

- [ ] **UI/UX Improvements**
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
