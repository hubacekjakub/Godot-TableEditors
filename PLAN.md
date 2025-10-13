# Godot Sheet Editor - Development Plan

This document outlines the development roadmap for the Godot Sheet Editor plugin, broken down into multiple phases with specific tasks.

> **Note**: Each task has a unique ID (e.g., `P1-001`) for easy reference in discussions and commits.

---

## Phase 1: Core Data Table Editor ✅ (In Progress)

**Goal**: Create a functional data table editor with basic CRUD operations and resource persistence.

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
  - [ ] `P1-017` Implement save functionality
  - [ ] `P1-018` Implement load functionality

---

## Phase 2: CSV Export/Import

**Goal**: Enable data exchange with external tools through CSV format support.

### Tasks

- [ ] **CSV Export**
  - [ ] `P2-001` Implement CSV export dialog
  - [ ] `P2-002` Add file path selection
  - [ ] `P2-003` Handle data serialization to CSV format
  - [ ] `P2-004` Support different CSV delimiters (comma, semicolon, tab)
  - [ ] `P2-005` Add header row option
  - [ ] `P2-006` Handle special characters and escaping

- [ ] **CSV Import**
  - [ ] `P2-007` Implement CSV import dialog
  - [ ] `P2-008` Add CSV file selection
  - [ ] `P2-009` Parse CSV data and detect column types
  - [ ] `P2-010` Map CSV columns to table columns
  - [ ] `P2-011` Add import preview
  - [ ] `P2-012` Handle malformed CSV gracefully

- [ ] **Export/Import Settings**
  - [ ] `P2-013` Save user preferences for CSV format
  - [ ] `P2-014` Add encoding options (UTF-8, etc.)
  - [ ] `P2-015` Implement batch export for multiple tables

- [ ] **Documentation**
  - [ ] `P2-016` Document CSV export workflow
  - [ ] `P2-017` Document CSV import workflow
  - [ ] `P2-018` Add troubleshooting guide for common CSV issues

---

## Phase 3: GDScript Class Integration

**Goal**: Automatically generate data tables from GDScript class definitions, enabling type-safe data structures.

### Tasks

- [ ] **Class Analysis**
  - [ ] `P3-001` Parse GDScript class files
  - [ ] `P3-002` Extract class properties and their types
  - [ ] `P3-003` Support for `int`, `float`, and `bool` types
  - [ ] `P3-004` Handle type hints and default values
  - [ ] `P3-005` Support exported variables (@export)

- [ ] **Table Generation**
  - [ ] `P3-006` Create "Generate from Class" dialog
  - [ ] `P3-007` Allow class file selection
  - [ ] `P3-008` Display detected properties and types
  - [ ] `P3-009` Generate table structure from class
  - [ ] `P3-010` Map GDScript types to column types

- [ ] **Class Synchronization**
  - [ ] `P3-011` Detect when source class changes
  - [ ] `P3-012` Offer to update table structure
  - [ ] `P3-013` Handle added/removed properties
  - [ ] `P3-014` Preserve existing data when possible

- [ ] **Bidirectional Support**
  - [ ] `P3-015` Generate GDScript class from existing table
  - [ ] `P3-016` Create typed array wrapper classes
  - [ ] `P3-017` Add helper methods for data access

- [ ] **Advanced Type Support**
  - [ ] `P3-018` Add support for `String` type
  - [ ] `P3-019` Add support for `Vector2` and `Vector3`
  - [ ] `P3-020` Add support for `Color`
  - [ ] `P3-021` Add support for enums
  - [ ] `P3-022` Add support for resource references

- [ ] **Documentation**
  - [ ] `P3-023` Document class-to-table workflow
  - [ ] `P3-024` Provide example classes
  - [ ] `P3-025` Add best practices guide
  - [ ] `P3-026` Create migration guide from manual tables

---

## Phase 4: Polish & Advanced Features (Future)

**Goal**: Enhance user experience and add power-user features.

### Potential Tasks

- [ ] **UI/UX Improvements**
  - [ ] `P4-001` Add keyboard shortcuts
  - [ ] `P4-002` Implement undo/redo system
  - [ ] `P4-003` Add search and filter functionality
  - [ ] `P4-004` Improve cell editing with specialized editors
  - [ ] `P4-005` Add data validation rules
  - [ ] `P4-006` Add auto-save option - moved from P1-019

- [ ] **Advanced Features**
  - [ ] `P4-007` Support for formulas and calculated columns
  - [ ] `P4-008` Add data sorting and filtering
  - [ ] `P4-009` Implement cell formatting (colors, fonts)
  - [ ] `P4-010` Add support for referenced data (foreign keys)
  - [ ] `P4-011` Create data visualization tools
  - [ ] `P4-012` Support column reordering (drag & drop) - moved from P1-010
  - [ ] `P4-013` Add column type selection (String, Int, Float, Bool) - moved from P1-011
  - [ ] `P4-014` Support row reordering (drag & drop) - moved from P1-014
  - [ ] `P4-015` Add row selection - moved from P1-015

- [ ] **Documentation & Examples**
  - [ ] `P4-016` Write usage guide for basic operations - moved from P1-021
  - [ ] `P4-017` Add code examples for loading data in scripts - moved from P1-022
  - [ ] `P4-018` Create example resource files - moved from P1-019
  - [ ] `P4-019` Create video tutorial (optional) - moved from P1-023

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

## Timeline Estimates

- **Phase 1**: 3-4 weeks
- **Phase 2**: 2-3 weeks
- **Phase 3**: 4-5 weeks
- **Phase 4**: Ongoing

*Note: Timeline estimates are approximate and may vary based on complexity and testing requirements.*

---

## Contributing

See individual phase tasks for areas where contributions are welcome. Please open an issue to discuss major changes before implementing them.

---

**Last Updated**: October 13, 2025
