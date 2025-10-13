# Godot Sheet Editor Plugin

A powerful data table editor plugin for Godot 4 that enables you to create, edit, and manage structured data directly within the Godot Editor.

## Features

### Current
- Custom editor dock with menu and editable grid
- Add and edit columns and rows
- Save data tables as Godot resources
- Use data tables directly in your game scripts

### Planned
- **CSV Export**: Export your data tables to CSV format for external use
- **GDScript Class Integration**: Generate data tables automatically from GDScript class definitions with support for `int`, `float`, and `bool` data types

## Usage

1. Copy the `addons/sheet_editor` folder into your Godot project
2. Enable the plugin in **Project Settings > Plugins**
3. Access the Sheet Editor from the new dock in the editor
4. Create your data tables and save them as resources
5. Load and use the resources in your game scripts

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
