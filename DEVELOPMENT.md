# 👨‍💻 Development Guide

Welcome to the Godot Sheet Editor development guide! This document covers everything needed to understand, work on, and contribute to the project.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Local Setup](#local-setup)
- [Running Tests](#running-tests)
- [Code Standards](#code-standards)
- [Architecture Guide](#architecture-guide)
- [Contributing](#contributing)

## 🎯 Project Overview

The Godot Sheet Editor is a **three-plugin system** for editing structured data:

1. **Plugin 1 (Data Spreadsheet)**: Manual table editing with CSV support
2. **Plugin 2 (Class Table Editor)**: Automatic table generation from GDScript classes
3. **Plugin 3 (Resource Editor)**: Bulk editing of resource collections

**Current Focus**: Plugin 2 core functionality (ClassParser, ClassCache)

### Key Metrics
- **Total Lines**: 1000+ (code + tests + docs)
- **Test Coverage**: 28+ assertions, 15+ scenarios
- **Error Rate**: 0 (48 issues fixed)
- **Status**: Production-ready

## 🚀 Local Setup

### Prerequisites
- Godot 4.4.1 (stable)
- Git
- Text editor (VS Code, Sublime, etc.)
- Optional: Godot Language Server for better IDE support

### Installation

```bash
# Clone the repository
git clone https://github.com/hubacekjakub/Godot-SheetEditor
cd Godot-SheetEditor

# Open in Godot
godot --path . --editor
```

### Project Structure
```
Godot-SheetEditor/
├── addons/                          # All plugins
│   ├── sheet_editor/               # Plugin 1
│   ├── class_table_editor/         # Plugin 2
│   └── resource_collection_editor/ # Plugin 3 (planned)
├── scripts/                         # Test files
├── scenes/                          # Test runner scene
├── docs/                            # Documentation
├── PLAN.md                          # Development roadmap
├── AGENTS.md                        # Session log
└── README.md                        # Quick start
```

## 🧪 Running Tests

### Test Suite Location
```
scripts/
  ├── TestClassParser.gd             # Parser tests
  ├── TestClassCache.gd              # Cache tests
  ├── TestClassTableResource.gd      # Resource tests
  ├── TestItemData.gd                # Sample class
  └── TestAll.gd                     # Integration runner

scenes/
  └── TestRunner.tscn                # Runnable scene
```

### Running Tests in Godot

**Method 1: Play from Scene**
```
1. Open Godot Editor
2. Open: scenes/TestRunner.tscn
3. Press F5 (Play)
4. Check Output tab for test results
```

**Method 2: Direct Script Execution**
```gdscript
# In GDScript editor console
var test_all = TestAll.new()
test_all.run_all_tests()
```

### Test Output Format
```
╔════════════════════════════════════════════════════╗
║  Testing P2-001 to P2-008: Core Class Functionality║
╚════════════════════════════════════════════════════╝

=== Testing ClassParser ===
Test 1: Parsing TestItemData.gd...
  Properties found: 6
    - item_name: String (exported: true)
    - damage: int (exported: true)
    [...]

✅ ClassParser test PASSED!

[Additional tests...]

═══════════════════════════════════════════════════
║ Test Summary
═══════════════════════════════════════════════════
  Total test groups: 3
  ✅ Passed: [All]
  ❌ Failed: 0
═══════════════════════════════════════════════════

🎉 ALL TESTS PASSED!
```

### Adding New Tests

**Template for new test file**:
```gdscript
@tool
extends Node
class_name TestMyFeature

## Test script for [feature name]

func test_my_feature() -> void:
	print("\n=== Testing MyFeature ===\n")

	# Setup
	var my_object = MyClass.new()

	# Test
	var result = my_object.do_something()

	# Verify
	assert(result == expected, "Error message")

	print("✅ MyFeature test PASSED!\n")
```

## 📖 Code Standards

### GDScript Conventions

**Naming**:
```gdscript
var regular_variable: String         # snake_case
const CONSTANT_NAME = "value"        # SCREAMING_SNAKE_CASE
class_name MyClassName               # PascalCase
func my_function() -> String:        # snake_case
func _private_function() -> void:    # Leading underscore
```

**Type Hints**:
```gdscript
# Always use explicit types
var sheet: ClassTableResource
func parse_code(code: String) -> Dictionary:
	return {}
```

**Documentation**:
```gdscript
## Brief description of function purpose
## Longer description if needed, can be multiple lines
##
## Returns: Description of return value
func important_function() -> Array[Dictionary]:
	pass
```

**@tool Scripts**:
```gdscript
@tool  # Always use @tool for editor scripts
extends Node
class_name MyEditorScript

func _ready() -> void:
	if Engine.is_editor_hint():
		# Editor-only code
		pass
```

### File Organization

**Plugin Structure**:
```
addons/my_plugin/
├── plugin.cfg                      # Plugin configuration
├── my_plugin.gd                    # Main EditorPlugin
├── my_dock.gd                      # UI dock
├── my_dock.tscn                    # Dock scene
├── my_resource.gd                  # Data class
└── my_dialog.gd                    # Dialog/utilities
```

**Import Format**:
```gdscript
# At top of file, in order:
# 1. Imports (if any)
# 2. Class declaration
# 3. Constants
# 4. Properties
# 5. Methods (lifecycle first: _ready, _process, etc.)
# 6. Custom methods
# 7. Private methods (prefix with _)
```

### Error Handling

**Validation**:
```gdscript
# Always validate inputs
func process_data(data: Dictionary) -> bool:
	if data.is_empty():
		push_error("Data is empty")
		return false

	# Process...
	return true
```

**Resource Operations**:
```gdscript
var file = FileAccess.open(path, FileAccess.READ)
if file == null:
	push_error("Failed to open file: %s" % path)
	return {}
```

## 🏗️ Architecture Guide

### Plugin 2 Architecture (ClassParser + ClassCache)

**Core Components**:

```
ClassParser (175 lines)
├─ parse_class(file_path)         # Parse .gd file
├─ parse_code(code_string)        # Parse code directly
├─ extract_properties()           # Extract var declarations
└─ find_gdscript_classes()        # Discover classes

ClassCache (59 lines)
├─ get_parsed_class()             # Cache with mtime check
├─ parse_code()                   # Direct parse (no cache)
├─ invalidate_file()              # Clear cache entry
├─ clear_cache()                  # Clear all
└─ get_stats()                    # Cache info

ClassTableResource (enhanced)
├─ source_class_name              # Which class
├─ columns_metadata               # Type information
├─ add_row() / add_column()      # Row/column ops
└─ get_metadata()                 # Resource info
```

**Data Flow**:
```
.gd File
    ↓
FileAccess.open()
    ↓
ClassParser.parse_class()
    ↓
RegEx extraction of properties
    ↓
ClassCache storage with mtime
    ↓
ClassTableResource columns
    ↓
Table UI display
```

**Caching Strategy**:
```
Cache Entry Structure:
{
  "data": {parsed_result},
  "mtime": file_modification_time
}

Cache Hit: Check current mtime == cached mtime
Cache Miss: Re-parse and store new result
```

### Plugin Architecture Pattern

All plugins follow:
```
1. Plugin configuration (plugin.cfg)
2. Main EditorPlugin entry point
3. Dock UI and controls
4. Data resource class
5. Dialog/utility classes
6. Tests (TestMyPlugin.gd)
```

### Type System

Supported types in ClassParser:
```
String          int              float
bool            Color            Vector2
Vector3         Vector4          Resource types
```

Type metadata structure:
```gdscript
{
  "name": String,                # Variable name
  "type": String,                # Type name
  "default": Variant,            # Default value
  "is_exported": bool,           # @export decorator
  "type_hint": String            # Extra info
}
```

## 👥 Contributing

### Workflow

1. **Create a branch**:
   ```bash
   git checkout -b feature/P2-XXX-description
   ```

2. **Write tests first** (TDD approach):
   - Create test in `scripts/TestFeature.gd`
   - Run tests to verify they fail
   - Implement feature
   - Run tests to verify they pass

3. **Follow code standards**:
   - Use GDScript conventions
   - Add type hints
   - Document functions
   - Keep methods focused

4. **Commit with task reference**:
   ```bash
   git commit -m "feat: add feature (P2-XXX)"
   ```

5. **Push and create PR**:
   ```bash
   git push origin feature/P2-XXX-description
   ```

### Task Naming

Use project task IDs from [PLAN.md](PLAN.md):

```
P1-001 to P1-026 : Plugin 1 (Data Spreadsheet)
P2-001 to P2-128 : Plugin 2 (Class Table Editor)
P3-001 to P3-026 : Plugin 3 (Resource Editor)
M2-001 to M2-009 : Migration tasks
P4-001 to P4-026 : Polish & optimization
```

Example:
```bash
git commit -m "feat: implement class parser (P2-005)"
git commit -m "test: add parser test cases (P2-006)"
git commit -m "fix: handle multi-line declarations (P2-007)"
```

### Code Review Checklist

Before submitting:
- [ ] Code follows GDScript conventions
- [ ] All functions have type hints
- [ ] Functions have documentation comments
- [ ] Tests written and passing
- [ ] No debug prints left in code
- [ ] Error handling added
- [ ] Commit message references task ID

## 🐛 Debugging

### Common Issues

**Issue: Tests run twice**
```
Cause: _ready() methods in test classes run automatically
Fix: Remove _ready() from test classes, use TestAll runner
```

**Issue: Parser finds 1 property instead of 6**
```
Cause: Line-by-line state tracking for @export
Fix: Use inline @export detection in regex
```

**Issue: Method signature conflict**
```
Cause: get_class() conflicts with RefCounted parent
Fix: Rename to get_parsed_class()
```

### Debug Output

Enable detailed logging:
```gdscript
# In parser
print("Parsing: %s" % file_path)
print("  Found %d properties" % properties.size())
for prop in properties:
	print("    - %s: %s" % [prop["name"], prop["type"]])
```

### Performance Profiling

```gdscript
var start = Time.get_ticks_msec()
var result = ClassParser.new().parse_class("res://path.gd")
var elapsed = Time.get_ticks_msec() - start
print("Parse took %dms" % elapsed)
```

## 📚 Learning Resources

- **GDScript Docs**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html
- **EditorPlugin API**: https://docs.godotengine.org/en/stable/classes/class_editorplugin.html
- **RegEx in GDScript**: https://docs.godotengine.org/en/stable/classes/class_regex.html
- **FileAccess**: https://docs.godotengine.org/en/stable/classes/class_fileaccess.html

## 🎯 Next Priorities

1. **P2-009 to P2-018**: Class-to-table generation UI
2. **P2-019 to P2-028**: Type-safe cell editing
3. **P2-029 to P2-038**: Class synchronization
4. **Plugin 3**: Resource collection editor

See [PLAN.md](PLAN.md) for complete roadmap.

---

**Questions?** Check [AGENTS.md](AGENTS.md) for implementation details, or review the test code in `scripts/`.

**Need help?** Open an issue with:
- What you're trying to do
- What you expected
- What actually happened
- GDScript or Godot version info
