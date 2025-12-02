# Presentation Proposal: Godot Plugins - The Editor's Secret Weapon

**Speaker:** Jakub Hubáček
**Duration:** 90 Minutes
**Theme:** The importance of in-editor tools and practical implementation.

---

## Abstract

Game development isn't just about the runtime experience; it's about the development experience. In this session, we explore why investing time in custom tools pays dividends in productivity and team sanity. We will move from the theory of "why plugins matter" to a deep-dive case study of a custom Data Editor, and finally, get our hands dirty with live examples of extending the Godot Editor itself.

---

## Opening Slides (1–3)

1.  **Title Slide:** "Godot Plugins – The Editor's Secret Weapon".
2.  **Speaker Introduction:** Who you are, your studio, and why you care about tools.
3.  **Agenda (Overview):**
    *   **Part 1 – Why Tools:** Pain points, ROI of tools, and general design principles.
    *   **Part 2 – The "How":** Anatomy of a plugin and live coding the editor.
    *   **Part 3 – The "What":** A deep dive case study: From simple Sheet Editor to complex Class Table Editor.

---

## Detailed Outline

### Part 1: Why Tools (≈25–30 Minutes)

#### 1. Opening: Why Tools, Why Now? (5 Minutes)

*   **The Hook (The Pain):** Establishing empathy through shared horror stories.
    *   **Questions for the Audience:**
        *   "Who here has ever broken a build because of a single typo in a data file?"
        *   "Who has spent more than an hour doing a repetitive task like renaming files, thinking 'there must be a better way'?"
        *   "Who has ever been afraid to change a game mechanic because updating all the data would take too long?"
*   **The Introduction:** Who is a Tool Developer?
    *   **Make Everyone Faster:** Automating repetitive tasks saves 20–30% of production time, freeing the team to focus on design and art.
    *   **Force Multipliers:** A single developer improves the daily work of dozens. Fewer delays, fewer errors, and smoother collaboration make tools essential for shipping complex games.
    *   **Bridge Tech & Creativity:** Turning messy real-world problems into clean, reliable workflows. Their innovation shapes how the entire studio makes games.
*   **The Promise:** You don't need a dedicated team. Godot makes this accessible to everyone.
*   **Thesis:** Every serious project (even solo) benefits from a few well-chosen tools.

#### 2. The "I'll Just Do It Manually" Trap (10–12 mins)
*   **The Myth:** "Writing a tool takes 5 hours, doing it manually takes 5 minutes."
*   **The Reality:** You do the manual task 100 times. You make mistakes 10 times. You hate your life 100% of the time.
*   **Simple ROI Formula:**
    *   `Tool_Time < Manual_Time * N + Cost_of_Bugs`
*   **The Value:**
    *   **Consistency:** Tools don't make typos.
    *   **Scalability:** Handling 10 items vs 1000 items.
    *   **Democratization:** Allowing designers/artists to tweak values without touching code.

#### 3. Tool Design Principles (10–12 mins)
*   **Editor-first UX:** The tool lives where people work (always-visible dock, no hidden scenes).
*   **Type Safety Over Clever Parsing:** Use Godot's native APIs (`Script.get_script_property_list()`) instead of regex on text files.
*   **Text-based Assets:** Prefer `.tres` and CSV so Git diffs stay readable.
*   **Fail in Editor, Not at Runtime:** Validate and yell at designers early.
*   **Small, Focused Tools:** Each tool solves one concrete pain point really well.

#### 4. Plugin Power Showcase (5–8 mins)
*   *Goal: Show what is possible to inspire the audience, without deep-diving.*
*   **Categories of Plugins:**
    *   **Content Creation:** *Phantom Camera* (Cinematic shots), *Cyclops Level Builder* (Blockout).
    *   **Workflow Enhancers:** *Orchestrator* (Visual Scripting), *Todo Manager* (Task tracking).
    *   **Data Management:** *Dialogic* (Narrative), *Godot SQLite* (Database).
*   **Format:** One slide per category, max 1–2 plugins each, screenshots over text.

---

### Part 2: The "How" - Extending the Editor (≈25–30 Minutes)


#### 5. Context: Industry Standards (Unreal & Unity) (5 mins)
*   **Unreal Engine:**
    *   **Editor Utility Widgets:** Build tools visually using UMG (Blueprints). No C++ needed for UI.
    *   **Blutilities:** Scripted actions on assets.
*   **Unity:**
    *   **Editor Scripting:** `EditorWindow` and `CustomEditor` (C#).
    *   **UI Toolkit:** Modern, web-like styling for tools.
*   **The Point:** The concepts are identical; only the syntax changes. We use Godot today because it's the fastest to demonstrate live.

#### 6. The Anatomy of a Godot Plugin (8–10 mins)
*   **What is a Plugin?** It's just a script with a `plugin.cfg`.
*   **The `EditorPlugin` Class:** The entry point.
*   **Lifecycle:**
    *   `_enter_tree()`: Setup (add UI, register types).
    *   `_exit_tree()`: Cleanup (remove UI, unregister types). **Crucial for stability!**
*   **The `@tool` Annotation:** Running code in the editor.
*   **Folder Structure:** `res://addons/my_plugin/`.
*   **Key API Pointers:** `EditorInterface`, `EditorInterface.get_selection()`.

#### 7. Live Demo: Extending the Editor (15 mins)
*   *Goal: Show how easy it is to start, with minimal code.*
*   **Example A: The "Panic Button" (Toolbar)**
    *   Add a simple button to the top container (`CONTAINER_TOOLBAR`).
    *   Make it print "Don't Panic" to the output.
    *   Highlight: Two functions (`_enter_tree`, `_exit_tree`) and you changed the editor.
*   **Example B: The Custom Dock**
    *   Create a simple `.tscn` with a Label and a Button.
    *   Add it to the side or bottom panel (`add_control_to_dock` / `add_control_to_bottom_panel`).
    *   Highlight: Any in-game UI skill transfers directly to plugin UI.
*   **Bonus (If Time / Pre-recorded): Inspector Plugin**
    *   Briefly show a prepared scene where an integer property has a custom editor (e.g., with a "Reset" button) without live-coding it.
    *   Message: You can go very deep, but you don't have to for tools to be useful.

### Part 3: The "What" - Case Study (≈30–35 Minutes)

#### 8. The Problem: Managing Game Data (5 mins)
*   **The Missing Feature:** Godot has no native "Data Table" (like Unreal).
*   **The Godot Way:** We use `Resource` files. One resource = One enemy type.
*   **The Scaling Issue:**
    *   10 Enemies = 10 Files. Not bad.
    *   100 Enemies = 100 Files. Chaos.
*   **The Friction:**
    *   Hard to get a complete overview.
    *   Balancing requires opening/closing dozens of Inspector windows.
    *   Designers struggle to compare values (e.g., "Is the Boss stronger than the Minion?").
*   **The Goal:** Visualize all enemies in one table. Less chaos, better readability, designer-friendly.
*   **Visual Comparison:**
    *   *Showcase:* A folder full of `.tres` files (The "Before").
    *   *Showcase:* The same data in a clean grid (The "After").

#### 9. The "Simple" Approach: Sheet Editor (10 mins)
*   **The Concept:** A generic spreadsheet inside Godot.
*   **The Name:** "Sheet Editor" (Yes, say it out loud carefully).
*   **Features:**
    *   Flexible, arbitrary tables.
    *   CSV imports/exports.
    *   Great for prototypes and quick data entry.
*   **The Limitation:**
    *   It's just strings. No type safety.
    *   "Is '10' a number or a string?" -> Runtime errors.
*   **Transition:** "We need something safer for production."

#### 10. The Solution: Class Table Editor (15 mins)
*   **The Concept:** A spreadsheet-like editor *inside* Godot that understands GDScript types.
*   **Walkthrough:**
    1.  **The Data Class:** Show a simple `EnemyData` class with `@export` variables.
    2.  **The Reflection:** Explain how `Script.get_script_property_list()` allows the tool to "read" the code.
    3.  **The UI:** Show the `Class Table Editor` dock.
    4.  **The Workflow:** Create a table -> Add rows -> Edit values (type-safe!).
    5.  **The Usage:** Show how `TableHandle` connects the data to the game at runtime.
    6.  **Workflow Impact:** How this changed your balancing process (designers edit data directly, fewer runtime crashes from bad data).

---

## Tips & Tricks for the Presentation

1.  **The "Demo Effect" Contingency:**
    *   Have the code for the "Live Demo" written out in a snippet or a hidden file. If you freeze, copy-paste.
    *   Have a video recording of the plugin working in case Godot crashes.

2.  **Visuals over Text:**
    *   When explaining `_enter_tree`, show a diagram of the Godot initialization flow, not just code.

3.  **Engage the Audience:**
    *   Ask: "Who has ever broken a game by making a typo in a JSON file?"

4.  **Godot Specifics:**
    *   Emphasize that the Godot Editor *is* a Godot Game. If you can make a UI in a game, you can make a plugin.
    *   Mention `EditorInterface.get_selection()` - it's the most useful function for context-aware tools.

## Suggestions for "Extending Editor" Examples

For the practical section, keep the code extremely simple.

**1. Adding a Toolbar Button:**
```gdscript
@tool
extends EditorPlugin

var button

func _enter_tree():
    button = Button.new()
    button.text = "My Tool"
    button.pressed.connect(_on_button_pressed)
    add_control_to_container(CONTAINER_TOOLBAR, button)

func _exit_tree():
    if button:
        remove_control_from_container(CONTAINER_TOOLBAR, button)
        button.queue_free()

func _on_button_pressed():
    print("Tool clicked!")
```

**2. Adding a Dock:**
```gdscript
@tool
extends EditorPlugin

var dock

func _enter_tree():
    dock = preload("res://addons/my_plugin/my_dock.tscn").instantiate()
func _exit_tree():
    remove_control_from_docks(dock)
    dock.queue_free()
```

**3. Inspector Plugin (Bonus - Concept):**
```gdscript
# A simplified InspectorPlugin to add a button to a property
extends EditorInspectorPlugin

func _can_handle(object):
    return object is MyCustomResource

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
    if name == "reset_me":
        var btn = Button.new()
        btn.text = "Reset Value"
        btn.pressed.connect(func(): object.reset_me = 0)
        add_custom_control(btn)
        return true # Return true to hide the default property editor
    return false
```

---

## Speaker Bio

## Speaker Bio

**Jakub Hubáček** is a developer at **Flying Rat Studio** with a passion for pipeline optimization. He specializes in creating "Force Multiplier" tools that bridge the gap between technical constraints and creative workflows, helping teams save time and focus on what matters—making great games.

