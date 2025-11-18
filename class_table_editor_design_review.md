# Class Table Editor – Design Review (Open Proposals Only)

**Date:** November 10, 2025 (updated: November 19, 2025)
**Scope:** This document tracks only proposals that are **not yet implemented**. All completed work (e.g. P1 RefCounted examples, P5 Option A inspector changes, and the P4 method rename discussion) has been removed or folded into the current baseline.

---

## High‑Level Summary of Remaining Proposals

- **P1 – Class discovery & registration (hybrid)**  
  Keep auto‑discovery for small projects, but add filters and an optional “registered classes only” mode. Some filter helpers exist already; the registration UX is still unimplemented.

- **P2 – Identifier / name column guidance (soft)**  
  Do **not** enforce a mandatory `name` column. Instead, add validation and helper APIs for common identifier patterns.

- **P3–P6 – Advanced table features (conceptual)**  
  Type validation on load, bulk row edits, column reordering, and export templates. These remain design ideas and have not been implemented.

- **P7 – Immutable row UIDs (planned)**  
  Per‑row stable UID column (optional, default ON for new tables) to decouple row identity from the visible name or index.

Use this document as the working list for **future work** on the Class Table Editor.

---

## P1 – Auto‑Discovery vs Manual Class Registration

### Current State

`ClassSelector` currently uses Godot’s global class list:

```gdscript
var classes = ProjectSettings.get_global_class_list()
for class_info in classes:
    # Add all classes to selector
```

This gives “it just works” behavior for small projects but becomes noisy in larger projects (too many irrelevant classes, slower mental filtering).

Some groundwork already exists:

- Helper methods such as `get_non_resource_classes` and `get_classes_inheriting_from`.
- These make it easier to build filters, but there is no user‑facing registration workflow yet.

### Proposal (Hybrid Discovery)

Introduce a **hybrid discovery model**:

```gdscript
# ClassSelector.gd
enum DiscoveryMode {
    AUTO,            # Existing behavior – show all eligible classes
    FILTERED,        # Use base-class and naming filters
    REGISTERED_ONLY  # Show only manually registered classes
}

var _filter_base_class: String = "RefCounted"  # Only show RefCounted descendants
var _exclude_patterns: Array = ["UI_", "Manager", "Controller"]

static func register_class(script: GDScript, category: String = "Game Data"):
    # Adds the class to a preferred list, grouped by category, shown at top of dialog
```

**Intended behavior:**

- **AUTO:** Zero‑config, ideal for small/teaching projects.
- **FILTERED:** Hide obvious non‑data classes via base‑class filters and name patterns.
- **REGISTERED_ONLY:** Large‑project mode – only show classes explicitly registered by the user/team.

### Rationale

- Keeps the “plug and play” experience for small experiments.
- Gives teams control over what appears in the selector as projects grow.
- Avoids forcing manual registration on everyone.

### Open Questions

- Where to persist the registered list (project settings vs `.tres` asset)?
- How to expose discovery mode:
  - Global plugin setting?
  - Per‑table override?
  - Per‑project profile?
- How to organize categories (folders, tags, or custom category strings)?

---

## P2 – Identifier / Name Column Strategy

### Current State

The editor often implicitly assumes the first column is something like `name`, but in practice:

- This is **not enforced** or validated.
- Some tables are purely index‑based.
- Many users already have their own `name` / `id` / `key` properties.

Hard‑enforcing a dedicated `name` column would conflict with flexible data modeling.

### Proposal (Soft Guidance, No Hard Requirement)

Do **not** enforce a mandatory name column. Instead:

1. Add a lightweight **class validation step** when binding a GDScript to a table.
2. Emit **warnings**, not errors, when no obvious identifier property exists.
3. Provide helper APIs that make identifier patterns easy to use.

Example validation:

```gdscript
func _validate_class_for_table(script: GDScript) -> Dictionary:
    var props = script.get_script_property_list()
    var has_identifier := false

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

### Key Ideas

- Treat identifiers as a **best practice**, not a constraint.
- Prefer helpers such as:

  ```gdscript
  var row = table.get_row_by_property("name", "Warrior")
  ```

  instead of forcing a `name` column into every table.
- Keep this aligned with P7 (UIDs) – UIDs handle stability, names remain flexible and human‑friendly.

---

## P3–P6 – Advanced Table & Inspector Features

These items are grouped as “advanced features” that can be implemented incrementally.

### 3. Type Validation on Table Load

**Problem:** When a bound class changes (rename, type change, property removal), existing tables can silently drift out of sync.

**Proposal:** Add a validation/migration step when loading or editing a table:

```gdscript
func _validate_against_class(script: GDScript) -> Array:
    var errors: Array[String] = []
    for col in columns_metadata:
        var prop = _find_property(script, col.name)
        if not prop:
            errors.append("Column '%s' no longer exists in class" % col.name)
        elif prop.type != col.type:
            errors.append("Column '%s' type changed: %s -> %s" % [col.name, col.type, prop.type])
    return errors
```

Questions:

- Are mismatches warnings only, or can they block saving?
- Do we offer guided fixes (rename column, change type, mark column as legacy)?

---

### 4. Bulk Edit Operations

**Goal:** Make multi‑row editing efficient.

- Multi‑select rows.
- Apply operations such as:
  - Set value for all selected rows.
  - Fill‑down / copy from first row.
  - Numeric operations (add, multiply).
  - String operations (find/replace).

Open design points:

- How to surface bulk operations (toolbar vs context menu)?
- Scope: selected rows only, or entire column?
- How to preview a bulk operation before committing?

---

### 5. Column Reordering

**Goal:** Allow users to reorder columns visually without breaking type mapping.

Constraints:

- Storage should remain logical: column index ↔ property name mapping must stay consistent.
- Reordering should be a **view concern**, not a data‑corrupting operation.

Proposal:

- Implement drag‑and‑drop of column headers in the UI.
- Maintain a separate “display order” list, distinct from the underlying schema.
- Provide an option to “apply display order to schema” if the user wants to commit the new logical order.

---

### 6. Export Templates

**Goal:** Make exports pluggable and scriptable so tables can be used for more than CSV.

Examples:

- Export to JSON.
- Export to GDScript stubs or enums.
- Custom exporters for specific engines or pipelines.

Sketch:

```gdscript
class_name TableExporter

func export_table(handle: TableHandle, path: String) -> Error:
    # Implement in subclasses: CSVExporter, JSONExporter, CodeExporter, etc.
    return OK
```

Design questions:

- How are exporters registered? (Global registry vs project‑local list.)
- How do we configure exporter options (e.g. pretty print, filters, target path)?

---

## P7 – Automatic Row UID Column

### Motivation

Row names and indices are fragile:

- Names can be edited freely.
- Rows can be reordered, inserted, or deleted.
- External references that rely on name/index can break.

### Proposal (Immutable Per‑Row UID)

Add an **optional, immutable UID column**:

- Generated automatically on row creation.
- Not exposed for normal editing (possibly hidden by default).
- Used internally (or by game code) for stable references.

Behavior ideas:

- New tables: UID column ON by default (configurable).
- Existing tables: UID can be added with a migration step.
- APIs to query by UID:

  ```gdscript
  var row = table.get_row_by_uid(some_uid)
  ```

### Interaction with Other Proposals

- **With P2:** UIDs remove pressure to over‑optimize names as identifiers; names can be fully human‑oriented.
- **With exports (P6):** UIDs can be included as stable keys in generated data.
- **With bulk edits and reordering:** Operations should preserve UIDs.

---

## Summary Table (Open Items Only)

| Proposal | Topic                              | Recommendation                                      | Breaking Change? |
|---------|-------------------------------------|-----------------------------------------------------|------------------|
| P1      | Class discovery & registration      | Hybrid: auto + filters + optional registration      | No               |
| P2      | Identifier/name column guidance     | Soft validation + helpers, no hard requirement      | No               |
| P3–P6   | Advanced features (validation, bulk edit, reordering, export) | Investigate and design incremental implementation   | No               |
| P7      | Immutable row UIDs                  | Planned; add as optional column for stability       | No (additive)    |

---

## Next Steps

1. **Prioritize:** Decide which proposal (P1, P2, P3–P6, P7) should ship first for real projects.
2. **Break down tasks:** Turn each proposal into concrete issues (UI, data model, tests).
3. **Prototype:** Start with low‑risk, high‑value items (e.g., P1 filters/registration UX, basic type validation).
4. **Document:** Update plugin README and in‑editor help once a proposal is implemented.
5. **Revisit this document:** Remove proposals once shipped, and keep this as a live roadmap for Class Table Editor.

