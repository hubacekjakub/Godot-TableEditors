# Class Table Editor - Design Review & Proposals

**Date:** November 10, 2025
**Status:** Discussion Phase - No Code Changes Yet
**Purpose:** Critical analysis of current architecture and proposed improvements

---

## Quick Summary of Proposed Changes

- **P1 – Use `RefCounted` instead of `Resource`** for row data classes (examples) to better match usage and reduce overhead.
- **P2 – Keep auto-discovery, add filters + optional registration** instead of going fully manual.
- **P3 – Do not enforce a name column**, but warn when an identifier-like property is missing.
- **P4 – Rename `TableHandle.to_resource()` to `build()`** (with a deprecation alias) for clearer semantics.
- **P5 – Improve TableHandle inspector** with search + dialog-based selection; consider de-emphasizing TableHandle as an exported property.
- **P9 – Add optional per-row UIDs** for stable references; default ON for new tables, usually hidden from the grid.

Below sections give short justifications rather than exhaustive arguments.

---

## Proposal 1: Resource vs RefCounted/Object Base Class

### Current State
`BaseUnit` and other user classes extend `Resource`:
```gdscript
@tool
extends Resource
class_name BaseUnit
```

### Proposal
Use `RefCounted` or `Object` as parent class instead of `Resource`.

**Why:** Row classes are used as transient DTOs converted from table rows; they are not assets.

**Conclusion:** Use `RefCounted` (or `Object` if needed) for example/row classes; `ClassTableResource` itself remains a `Resource`.

**Notes:**
- Exported properties work fine on `RefCounted` in Godot 4.
- This is mostly a documentation + example change, not a core rewrite.

---

## Proposal 2: Auto-Discovery vs Manual Class Registration

### Current State
`ClassSelector` scans all classes using `ProjectSettings.get_global_class_list()`:
```gdscript
var classes = ProjectSettings.get_global_class_list()
for class_info in classes:
    # Add all classes to selector
```

### Proposal
Implement manual class registration instead of auto-discovery.

**Why:** Pure auto-discovery doesn’t scale to large projects; pure manual registration adds too much friction.

**Hybrid approach:**

```gdscript
# ClassSelector.gd
enum DiscoveryMode {
    AUTO,           # Current behavior - show all classes
    FILTERED,       # Show classes matching criteria
    REGISTERED_ONLY # Show only manually registered classes
}

# Add filter in dialog
var _filter_base_class: String = "RefCounted"  # Only show RefCounted descendants
var _exclude_patterns: Array = ["UI_", "Manager", "Controller"]

# Allow manual registration for organization
static func register_class(script: GDScript, category: String = "Game Data"):
    # Adds to preferred list, shows at top of dialog with category
```

**Effects:**
- Keeps zero-config experience for small projects.
- Gives control and structure for large projects.
- No breaking changes; mostly UI/UX work in the selector dialog.

---

## Proposal 3: Mandatory Name Column

### Current State
Table assumes first column is "name" or similar, but this is:
- Not enforced
- Not validated
- Entirely dependent on user's class definition

### Proposal
Always add automatic `row_name` or `name` column to tables.

**Why:** Names are useful but not universal; some tables are purely index-based, and users may already have `name`/`id` properties.

**Soft approach:** Encourage, don’t enforce.

```gdscript
# In PropertyInspector when scanning class
func _validate_class_for_table(script: GDScript) -> Dictionary:
    var props = script.get_script_property_list()
    var has_identifier = false

    for prop in props:
        if prop.name in ["name", "id", "key", "identifier"]:
            has_identifier = true
            break

    return {
        "valid": true,
        "warnings": [
            "No identifier property found. Consider adding 'name: String' for better usability."
        ] if not has_identifier else []
    }
```

**Key ideas:**
- Add a validation warning when a class has no likely identifier property.
- Document best practice (first export = identifier) instead of hard rules.
- Provide helpers like `get_row_by_property("name", value)` rather than forcing a column.

---

## Proposal 4: TableHandle Method Naming

### Current State
```gdscript
var handle: TableHandle = table_resource.create_handle()
var unit: BaseUnit = handle.to_resource(BaseUnit)
```

### Proposal
Rename `to_resource()` to better-sounding method name.

**Why:** `to_resource()` is vague and becomes wrong once row classes use `RefCounted`.

**Conclusion:**
- Introduce `build(MyClass)` as the primary API: `var unit: BaseUnit = handle.build(BaseUnit)`.
- Keep `to_resource()` as a deprecated alias for one version, with a warning.

---

---

## Additional Ideas (Short)

### 5. Type Validation on Table Load
**Problem:** User changes class definition, old table has wrong types
**Proposal:** Add migration/validation system:
```gdscript
# When loading table
func _validate_against_class(script: GDScript) -> Array:
    var errors = []
    for col in columns_metadata:
        var prop = _find_property(script, col.name)
        if not prop:
            errors.append("Column '%s' no longer exists in class" % col.name)
        elif prop.type != col.type:
            errors.append("Column '%s' type changed: %s -> %s" % [col.name, col.type, prop.type])
    return errors
```

### 6. Bulk Edit Operations
Multi-select rows and apply actions (set value, fill-down, find/replace) instead of editing one-by-one.

### 7. Column Reordering
Allow drag-and-drop of column headers to reorder logically without affecting underlying data mapping.

### 8. Export Templates
Pluggable export system (CSV/JSON/custom):
```gdscript
class_name TableExporter
func export_table(handle: TableHandle, path: String) -> Error
```

### 9. Automatic Row UID Column
Add per-row immutable UIDs (optional, default ON) so that row identity survives renames and reordering, while names remain flexible.

---

## Proposal 5: Inspector Integration Improvements

### Current State
TableHandle inspector plugin provides basic UI:
- `EditorResourcePicker` for table selection
- `OptionButton` dropdown for row selection
- Vertical stacking of controls
- Assumes first column is "name"

**Current Implementation:**
```gdscript
# table_handle_editor_property.gd
func _init():
    container = VBoxContainer.new()

    var table_label = Label.new()
    table_label.text = "Table:"
    container.add_child(table_label)

    table_picker = EditorResourcePicker.new()
    table_picker.base_type = "ClassTableResource"
    container.add_child(table_picker)

    var row_label = Label.new()
    row_label.text = "Row:"
    container.add_child(row_label)

    row_selector = OptionButton.new()
    container.add_child(row_selector)
```

### Problems

1. **Visual Clutter**: Takes up 4 rows in inspector (2 labels + 2 controls)
2. **No Preview**: Can't see selected row's data without opening table
3. **Poor Discoverability**: No indication what class this table uses
4. **Limited Search**: Dropdown is unusable for 100+ rows
5. **No Validation**: Invalid row_name shows nothing, no error message
6. **Assumes Structure**: Hardcoded first column as "name" (relates to Proposal 3)
7. **No Quick Edit**: Can't modify cell values inline
8. **Static Layout**: Always vertical, even when horizontal would fit better

### Improvement Proposals

#### Option A: Compact Single-Line Mode
**Concept:** Use horizontal layout with smart truncation
```gdscript
[Table: base_unit_table.tres ▼] → [Row: "Warrior" ▼] [👁️]
```

**Pros:**
- Saves vertical space (1 line vs 4)
- Standard pattern (similar to NodePath picker)
- Eye icon opens preview popup

**Cons:**
- Less clear labeling
- May truncate on narrow inspectors

#### Option B: Embedded Preview Card
**Concept:** Show selected row data below pickers
```
Table: base_unit_table.tres ▼
Row: Warrior ▼
┌─────────────────────────────┐
│ Warrior                     │
│ HP: 100  ATK: 15  SPD: 5.0  │
│ Color: Red                  │
└─────────────────────────────┘
```

**Pros:**
- Immediate feedback on selection
- No need to open table editor
- Validates data is correct

**Cons:**
- Takes MORE space than current
- Complexity for many columns

#### Option C: Searchable Row Selector
**Concept:** Replace OptionButton with LineEdit + autocomplete
```
Table: base_unit_table.tres ▼
Row: [War|_________]
     ┌──────────┐
     │ Warrior  │  ← Autocomplete dropdown
     │ Warlock  │
     └──────────┘
```

**Pros:**
- Scalable to 1000+ rows
- Faster than scrolling dropdown
- Common pattern (like node selection)

**Cons:**
- More complex to implement
- Requires fuzzy matching logic

#### Option D: Inspector Plugin for TableHandle Properties
**Concept:** Make TableHandle itself a full inspector section
```
▼ My Unit (TableHandle)
    Table Resource: base_unit_table.tres
    Row Name: Warrior
    ▼ Preview (Read-Only)
        unit_name: "Warrior"
        max_health: 100
        attack_damage: 15
        movement_speed: 5.0
        description: "A strong melee fighter"
        unit_color: (255, 0, 0, 255)
```

**Pros:**
- Native inspector feel
- Expandable/collapsible preview
- Could make preview editable (inline table editing!)
- Shows typed values

**Cons:**
- Most complex to implement
- Need to parse class properties dynamically
- Performance for many TableHandles on one object

#### Option E: Hybrid Compact + Dialog
**Concept:** Minimal inline, button opens full dialog
```
TableHandle: base_unit_table.tres → Warrior [Edit...]

[Edit...] opens:
┌────────────────────────────────────────┐
│ Select Row from base_unit_table.tres  │
├────────────────────────────────────────┤
│ Search: [War|_______________]         │
├────────────────────────────────────────┤
│ ☑ Warrior     HP: 100  ATK: 15        │
│ ☐ Warlock     HP: 80   ATK: 25        │
│ ☐ Warden      HP: 120  ATK: 10        │
├────────────────────────────────────────┤
│ Preview:                               │
│ unit_name: Warrior                     │
│ max_health: 100                        │
│ attack_damage: 15                      │
│ ...                                    │
├────────────────────────────────────────┤
│           [Cancel]  [Select]           │
└────────────────────────────────────────┘
```

**Pros:**
- Best of both worlds: compact + powerful
- Standard Godot pattern (like NodePath, Script, etc.)
- Dialog can have search, preview, filters
- Doesn't clutter inspector

**Cons:**
- Extra click to change row
- Dialog implementation effort

#### Option F: Visual Row Picker (Thumbnail Grid)
**Concept:** If table has Color/Texture columns, show visual grid
```
Table: unit_table.tres
Row: [🟥 Warrior ▼]
     Grid View:
     ┌────┬────┬────┐
     │ 🟥 │ 🟦 │ 🟩 │  ← Color-coded units
     │ War│Wiz │Ran │
     └────┴────┴────┘
```

**Pros:**
- Great for visual data (colors, icons, textures)
- Fast recognition for artists
- Unique to this plugin

**Cons:**
- Only works for specific data types
- Doesn't scale to text-only tables
- Complex layout logic

### Critical Analysis

#### Current Inspector is "Good Enough" For:
- Small tables (< 20 rows)
- Simple workflows (set once, forget)
- Users who don't mind opening table editor

#### Current Inspector FAILS For:
- Large tables (100+ rows) → Dropdown becomes unusable
- Rapid iteration (changing rows frequently) → Too many clicks
- Data validation (is this the right row?) → No preview
- Professional workflows → Looks amateurish compared to built-in Godot inspectors

### 🎯 Recommendation

**Implement Option E (Hybrid) + Option C (Search)**

**Phase 1: Quick Win (Low Effort)**
```gdscript
# Replace OptionButton with LineEdit + autocomplete
var row_input: LineEdit
var autocomplete_popup: PopupMenu

func _on_row_text_changed(text: String):
    _show_autocomplete_matches(text)
```
- ✅ Solves scalability (1000+ rows)
- ✅ Minimal UI change
- ✅ Standard pattern (like FileDialog)

**Phase 2: Enhanced (Medium Effort)**
```gdscript
# Add compact mode with edit button
var edit_button: Button

func _on_edit_clicked():
    var dialog = RowSelectionDialog.new()
    dialog.configure(current_handle.table_resource)
    dialog.row_selected.connect(_on_dialog_row_selected)
    # Dialog has search, preview, filters
```
- ✅ Power user features in dialog
- ✅ Keeps inspector clean
- ✅ Familiar UX (NodePath picker style)

**Phase 3: Polish (High Effort)**
```gdscript
# Add inline preview (Option B)
var preview_panel: PanelContainer
var preview_grid: GridContainer

func _update_preview():
    var data = current_handle.get_row_data()
    for key in data:
        # Show key-value pairs in compact grid
```
- ✅ Visual feedback
- ✅ Validates selection
- ✅ Professional appearance

### Alternative: Do Nothing?

**If we adopt Proposal 4 (rename to `build()`)**, the inspector becomes LESS important:

```gdscript
# Old pattern (requires inspector):
@export var unit_handle: TableHandle
func _ready():
    var unit = unit_handle.to_resource(BaseUnit)

# New pattern (direct reference):
@export var unit_table: ClassTableResource
@export var unit_name: String = "Warrior"
func _ready():
    var handle = unit_table.get_row_by_name(unit_name)
    var unit = handle.build(BaseUnit)
```

**This suggests:**
- TableHandle might be an internal implementation detail, not exposed property
- Users might prefer separate exports for `table` + `row_name`
- Current inspector might be solving the wrong problem

### 💡 Radical Alternative: Remove TableHandle from Inspector Entirely

**Proposal:** Don't expose TableHandle as @export at all. Instead:

```gdscript
# User script
@export var unit_table: ClassTableResource
@export var unit_row: String  # Just a string, uses normal StringName inspector

func _ready():
    # Get data via table API
    var unit_data = unit_table.get_row_by_name(unit_row)
    var unit = unit_data.build(BaseUnit)
```

**This means:**
- No custom inspector needed
- Uses built-in String inspector (autocomplete could be added via EditorProperty for String)
- Clearer separation: table = data source, row = lookup key
- TableHandle becomes purely a return type, not a property type

**Trade-off:**
- Less "magic" (no single property for table+row)
- More explicit (clearer what's happening)
- Better for large projects (two focused inspectors vs one complex one)

---

## Summary Update

| Proposal | Recommendation | Confidence | Breaking Change? |
|----------|---------------|------------|------------------|
| 1. RefCounted base | ✅ **Support** - Do it | 🔥🔥🔥🔥🔥 High | Minor (examples only) |
| 2. Manual registration | 🔀 **Hybrid** - Add filtering, keep auto | 🔥🔥🔥🔥 High | No |
| 3. Mandatory name | ⚠️ **Soft** - Warn, don't enforce | 🔥🔥🔥 Medium | No |
| 4. Rename method | ✅ **build()** - Clear and concise | 🔥🔥🔥🔥 High | Yes (add deprecation) |
| 5. Inspector UX | 🔀 **Phase 1: Search**, **Consider: Remove TableHandle export** | 🔥🔥🔥🔥 High | Potentially major |
| 9. Row UID column | ✅ **Implement as optional**, default ON | 🔥🔥🔥🔥 High | No (additive) |

**Key Insight:** Proposal 9 (UID) actually STRENGTHENS Proposal 3's argument against mandatory name column. If UIDs handle stability, names can be fully flexible.

---

## Next Steps

1. **Discuss & Decide**: Review each proposal, decide on direction
2. **Prioritize**: Which changes give most value for effort?
3. **Plan Implementation**: Task breakdown for approved changes
4. **Update Documentation**: Reflect decisions in README/API docs
5. **Deprecation Path**: If breaking changes, add warnings first

**No code changes until consensus reached.**
