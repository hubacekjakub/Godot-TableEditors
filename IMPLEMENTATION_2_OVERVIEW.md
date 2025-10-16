# Implementation 2: Class Table Editor - Quick Overview

This document explains what Implementation 2 does in simple terms with practical examples.

---

## What Problem Does This Solve?

You want to create game data (enemies, items, NPCs, etc.) in a spreadsheet-like table, but you also want:
- **Type safety** - can't put text in a number field
- **Autocomplete** - IDE helps you access the data
- **Class definitions** - data structure is defined in GDScript
- **Easy editing** - spreadsheet interface for bulk data entry

## How It Works

### Step 1: Create a Data Class

You define what an "Enemy" looks like in GDScript:

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

### Step 2: Create a Table from That Class

1. Open **Class Table** dock in Godot editor
2. Click **"New Table from Class"**
3. Select your `EnemyData.gd` file
4. The plugin reads your class and creates a table with columns:
   - health (int)
   - damage (int)
   - defense (int)
   - luck (float)
   - agility (bool)

### Step 3: Fill in Your Data

The table looks like a spreadsheet:

| Row Name | health | damage | defense | luck | agility |
|----------|--------|--------|---------|------|---------|
| Goblin   | 50     | 8      | 3       | 0.3  | true    |
| Dragon   | 500    | 100    | 50      | 0.8  | false   |
| Slime    | 20     | 2      | 1       | 0.1  | true    |
| Orc      | 150    | 25     | 12      | 0.4  | true    |

**Type enforcement**:
- You can't type "hello" in the health column (it's an int!)
- Boolean columns show checkboxes
- Float columns accept decimals

### Step 4: Use the Data in Your Game

You have **several options** for using this data:

#### Option A: Simple Dictionary Access
```gdscript
# In your enemy spawner script:
@export var enemy_table: ClassTableResource
@export var enemy_type: String = "Goblin"

func spawn_enemy():
    var stats = enemy_table.get_row_data(enemy_type)
    var enemy = EnemyScene.instantiate()
    enemy.health = stats["health"]  # Dictionary access
    enemy.damage = stats["damage"]
    add_child(enemy)
```

#### Option B: Typed Resource Access (Recommended)
```gdscript
# In your enemy spawner script:
@export var enemy_table: ClassTableResource
@export var enemy_type: String = "Goblin"

func spawn_enemy():
    var stats: EnemyData = enemy_table.get_row_as_resource(enemy_type)
    var enemy = EnemyScene.instantiate()
    enemy.health = stats.health  # Fully typed! Autocomplete works!
    enemy.damage = stats.damage
    add_child(enemy)
```

#### Option C: Export Individual Resources
```gdscript
# Generate separate .tres files for each enemy:
# res://data/enemies/goblin.tres
# res://data/enemies/dragon.tres
# etc.

# Then in your script:
@export var enemy_data: EnemyData  # Direct resource reference!

func _ready():
    health = enemy_data.health  # Native Godot workflow
    damage = enemy_data.damage
```

#### Option D: Batch Operations
```gdscript
# Get all enemies at once:
var all_enemies: Array[EnemyData] = enemy_table.get_all_as_array()

for enemy in all_enemies:
    print("%s has %d health" % [enemy.name, enemy.health])

# Filter with custom logic:
var strong_enemies = all_enemies.filter(
    func(e): return e.health > 100
)
```

---

## Key Features

### ✅ Type Safety
- Can't put wrong data types in columns
- Validation happens as you type
- Prevents bugs from typos

### ✅ Sync with Class
When you modify `EnemyData.gd` (add a property, change a type), the plugin:
- Detects the change
- Shows you a diff (what changed)
- Offers to update the table structure
- Preserves your existing data when possible

### ✅ CSV Export/Import
- Export table to CSV for editing in Excel/Google Sheets
- CSV includes type information (`#TYPES:int,int,int,float,bool`)
- Import validates data against types
- Great for working with game designers

### ✅ Bidirectional
- Create table from class (class → table)
- Generate class from table (table → class)
- Start from either direction!

---

## Comparison with Implementation 1 (Spreadsheet)

| Feature | Implementation 1 (Spreadsheet) | Implementation 2 (Class Table) |
|---------|--------------------------------|--------------------------------|
| **Columns** | Manual creation, any name | Generated from GDScript class |
| **Types** | Optional, loose | Enforced by class definition |
| **Editing** | Free-form | Type-validated |
| **Runtime** | Dictionary access | Typed resource instances |
| **Use Case** | Flexible, ad-hoc data | Structured, typed game data |
| **Best For** | Prototyping, one-off tables | Production, large datasets |

---

## Example: Item Database

### 1. Define Item Class
```gdscript
class_name ItemData
extends Resource

enum ItemType { WEAPON, ARMOR, CONSUMABLE, QUEST }

@export var id: int = 0
@export var name: String = ""
@export var type: ItemType = ItemType.CONSUMABLE
@export var icon: Texture2D
@export var price: int = 0
@export var stackable: bool = true
@export var max_stack: int = 99
```

### 2. Create Table

Table automatically has columns for all properties, including:
- Enum dropdown for `type`
- Resource picker for `icon`
- Checkbox for `stackable`

### 3. Fill Data

| id | name | type | icon | price | stackable | max_stack |
|----|------|------|------|-------|-----------|-----------|
| 1 | Health Potion | CONSUMABLE | [icon] | 50 | true | 99 |
| 2 | Iron Sword | WEAPON | [icon] | 200 | false | 1 |
| 3 | Leather Armor | ARMOR | [icon] | 150 | false | 1 |

### 4. Use in Game
```gdscript
# In inventory system:
@export var item_database: ClassTableResource

func add_item_by_id(item_id: int):
    var item: ItemData = item_database.get_row_as_resource(str(item_id))
    if item:
        inventory.append(item)
        print("Added: %s (%s)" % [item.name, ItemType.keys()[item.type]])
```

---

## Future Enhancements (Phase 4)

### Custom Export Property (Under Investigation)

Ideally, we'd like to do this:

```gdscript
@export var item_database: ClassTableResource
@export_table_row("item_database") var selected_item: String  # Shows dropdown!
```

This would show a dropdown in the inspector with all row names from the table.

**Status**: Requires custom EditorInspectorPlugin. Complexity TBD.

**Workaround**: Generate an enum from row names:
```gdscript
# Auto-generated by plugin:
enum ItemID {
    HEALTH_POTION,
    IRON_SWORD,
    LEATHER_ARMOR
}

@export var selected_item: ItemID = ItemID.HEALTH_POTION
```

---

## When to Use Implementation 2

**✅ Use Class Tables when:**
- You have structured, typed game data (enemies, items, levels)
- You want type safety and autocomplete
- Multiple people edit the data (CSV workflow)
- Data structure might change (sync feature helps)
- You need to generate code from tables

**❌ Use Implementation 1 (Spreadsheet) when:**
- Prototyping or experimental data
- Structure changes frequently and unpredictably
- Data is one-off or temporary
- You don't need type enforcement
- Simple lookup tables

---

## Development Status

**Current**: Not started
**Next Steps**:
1. Copy Implementation 1 code (P2-001 to P2-012)
2. Build GDScript parser (P2-013 to P2-025)
3. Create table from class (P2-026 to P2-038)

See [PLAN_IMPLEMENTATION_2.md](PLAN_IMPLEMENTATION_2.md) for detailed task breakdown.

---

**Last Updated**: October 17, 2025
