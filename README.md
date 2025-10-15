# Godot Sheet Editor Plugin

A powerful data table editor plugin for Godot 4 that explores **three distinct approaches** to data management within the Godot Editor, designed for academic research and practical game development.

## Three Implementation Approaches

This plugin demonstrates three different ways to work with structured data in Godot:

### 1. **Spreadsheet** - Excel-Style Editor
A standalone spreadsheet-like editor for creating arbitrary data tables without predefined schemas.

**Use Case**: Item lists, enemy stats, dialogue trees, configuration data

**Features**:
- Manual column/row creation and editing
- CSV export/import for external tools
- Save as Godot resources (.tres files)
- No code required

### 2. **Class Table** - GDScript Class Integration
Automatically generate and maintain tables based on GDScript class definitions.

**Use Case**: Type-safe data structures mirroring your game classes

**Features**:
- Parse GDScript classes and extract typed properties
- Auto-generate table columns from class structure
- Bidirectional sync: class → table and table → class
- Type enforcement (int, float, bool, String, Vector2, etc.)

### 3. **Resource Editor** - Multi-Resource Collection Editor
Edit multiple resource files of the same type in a unified table view.

**Use Case**: Managing collections of similar game objects (enemies, items, levels)

**Features**:
- Load multiple .tres files from a folder
- Display as table: rows = resource files, columns = properties
- Edit all resources at once in spreadsheet format
- Save changes back to individual files
- Bulk operations and filtering

## Project Structure

```
addons/sheet_editor/
├── core/                          # Shared utilities (minimal, optional)
│   ├── grid_helpers.gd           # Basic grid math/helpers
│   └── common_types.gd           # Shared enums/constants
│
├── spreadsheet/                   # Implementation 1: Excel-style
│   ├── spreadsheet_plugin.gd     # Plugin entry point
│   ├── spreadsheet_dock.gd       # Main dock UI
│   ├── spreadsheet_dock.tscn     # Dock scene
│   ├── spreadsheet_resource.gd   # Sheet resource class
│   ├── create_table_dialog.gd    # Create new table dialog
│   ├── create_table_dialog.tscn  # Dialog scene
│   ├── csv_export_dialog.gd      # CSV export
│   └── csv_import_dialog.gd      # CSV import
│
├── class_table/                   # Implementation 2: Class integration
│   ├── class_table_plugin.gd     # Plugin entry point
│   ├── class_table_dock.gd       # Main dock UI
│   ├── class_table_resource.gd   # Typed sheet resource
│   ├── class_parser.gd           # Parse GDScript files
│   └── ... (to be implemented)
│
├── resource_editor/               # Implementation 3: Resource collections
│   ├── resource_editor_plugin.gd # Plugin entry point
│   ├── resource_editor_dock.gd   # Main dock UI
│   └── ... (to be implemented)
│
├── plugin.cfg                     # Main plugin configuration
└── sheet_editor_plugin.gd         # Main plugin entry (mode switcher)
```

**Current Status**: All files are currently in the root `addons/sheet_editor/` folder. They will be moved to `spreadsheet/` folder once Implementation 1 is complete.

Each implementation is **independent** and can be used, modified, or removed separately while sharing common core functionality.

## Current Status

- 🚧 **Implementation 1 (Spreadsheet)**: Core functionality complete, finishing CSV export/import and refactoring
  - ✅ Grid editing, columns/rows management
  - ✅ Resource persistence (Sheet.gd)
  - ⏳ CSV export/import (in progress)
  - ⏳ Move to `spreadsheet/` folder structure
- ⏳ **Implementation 2 (Class Table)**: Planned (will duplicate and adapt Implementation 1)
- ⏳ **Implementation 3 (Resource Editor)**: Planned (will duplicate and adapt Implementation 1)

See [PLAN.md](PLAN.md) for detailed development roadmap and task tracking.

## Installation & Usage

1. Copy the `addons/sheet_editor` folder into your Godot project
2. Enable the plugin in **Project Settings > Plugins**
3. Access the Sheet Editor from the bottom panel dock
4. Choose your preferred implementation approach
5. Create and save your data tables as resources
6. Load and use the resources in your game scripts

## Academic Purpose

This project serves as a comparative study of different data management patterns in game engines, demonstrating:
- Manual data entry vs. code-driven schemas
- Single-table editing vs. bulk resource management
- Trade-offs between flexibility and type safety

Each implementation can be studied independently or compared side-by-side.

## Development

### VS Code Tasks

This project includes convenient VS Code tasks:

- **🎨 Open Godot Editor** - `Ctrl+Shift+B` (default build task)
- **▶️ Run Game** - Quick test the game
- **🐛 Debug Godot Editor** - Editor with debug visualizations
- **🔍 Run Game with Remote Debug** - Game with remote debugging

See [`.vscode/TASKS_REFERENCE.md`](.vscode/TASKS_REFERENCE.md) for detailed usage instructions.

## License

This project is licensed under the [MIT License](LICENSE).
You are free to use, modify, and distribute this template in your own projects.

---

**💡 Pro Tip:** Star this repo if it helps your workflow! Questions? Open an issue or check the [live demo](https://hubacekjakub.itch.io/godot-quick-start) to see everything working.
