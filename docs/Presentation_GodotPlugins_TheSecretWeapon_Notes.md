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

### Part 2: The "How" - Tools Across All Engines (≈25–30 Minutes)

#### 5. The Tool Ecosystem: Unreal, Unity & Godot (12-15 mins)

*   **The Universal Truth:** Every major engine has extensibility. The concepts are identical; only the syntax changes.
*   **Format:** Categorize by *what problem the tool solves*, show examples from all three engines.

---

**Category 1: Content Creation & Level Design**

| Purpose | Unreal | Unity | Godot |
|---------|--------|-------|-------|
| **Level Blockout** | *UE4 Voxel Plugin* | *ProBuilder* (now built-in) | *Cyclops Level Builder* |
| **Cinematic Camera** | *CineCameraRig Crane* | *Cinemachine* (now built-in) | *Phantom Camera* |
| **Terrain & World** | *Voxel Plugin* by Phyronnaz | *Gaia* by Procedural Worlds | *Terrain3D* by TokisanGames |
| **Procedural Generation** | *Dungeon Architect* | *Dungeon Architect* | *Scatter* by HungryProton |

*Key Insight:* All engines let you build worlds faster. The question is: *"Does your project need a custom tool, or an existing one?"*

---

**Category 2: Data & Content Management**

| Purpose | Unreal | Unity | Godot |
|---------|--------|-------|-------|
| **Data Tables** | *Easy DataTable* by Jianyang | *Odin Inspector* by Sirenix | *Your Class Table Editor* |
| **Dialogue & Narrative** | *Dialogue Plugin* by Code Sprites | *Yarn Spinner* by Secret Lab | *Dialogic* by Copypasta |
| **Localization** | *Localization Manager* | *I2 Localization* by Inter Illusion | *(external: POEditor, Weblate)* |
| **Database** | *SQLite3UE4* by Justnwhatever | *SQLite4Unity3D* by Roberto Huertas | *Godot SQLite* by 2shady4u |

*Key Insight:* Unreal has native Data Tables - that's exactly what we're building for Godot!

---

**Category 3: Visual Scripting & Logic**

| Purpose | Unreal | Unity | Godot |
|---------|--------|-------|---------|
| **Visual Scripting** | *LogicDriver Pro* by Recursoft | *Bolt* by Ludiq (now Unity) | *Orchestrator* by Vahera |
| **State Machines** | *SUDS Pro* by Elhoussine | *Playmaker* by Hutong Games | *LimboAI* by Serhii Snitsaruk |
| **Behavior Trees** | *BTSM Pro* by Syntechx | *NodeCanvas* by Paradox Notion | *Beehave* by bitbrain |

*Key Insight:* Visual tools democratize development. Designers can tweak logic without touching code.

---

**Category 4: Audio & Middleware**

| Purpose | Unreal | Unity | Godot |
|---------|--------|-------|---------|
| **Audio Middleware** | *FMOD for UE* by Firelight | *FMOD for Unity* by Firelight | *FMOD GDExtension* by alessandrofama |
| **Adaptive Music** | *Audio Synesthesia* | *Master Audio* by Dark Tonic | *Resonate* by Cloaked Games |
| **Sound Design** | *MetaSounds* (native) | *Audio Toolkit* by ClockStone | - |

*Key Insight:* Some tools live *outside* the engine entirely. FMOD/Wwise have their own editors - integration plugins just bridge the gap.

---

**Category 5: Workflow & Productivity**

| Purpose | Unreal | Unity | Godot |
|---------|--------|-------|---------|
| **Task Tracking** | *UE4 Task Manager* | *TODO Highlighter* by Thomas F | *Todo Manager* by OrigamiDev |
| **Asset Management** | *Project Cleaner* by Starter | *Asset Hunter PRO* by HeurekaGames | *Godot File Editor* by fenix-hub |
| **Quick Actions** | *Blutility* scripts | *Editor Console Pro* by FlyingWorm | *Command Palette* by IvanSkoworoda |
| **Build Automation** | *BuildGraph* (native) | *Super Build Pipeline* by Unity | *(external: GitHub Actions)* |

*Key Insight:* Not every tool needs to be inside the engine. External tools (Git, CI/CD, spreadsheets) are also part of your pipeline.

---

**Category 6: Debugging & Profiling**

| Purpose | Unreal | Unity | Godot |
|---------|--------|-------|---------|
| **Console/Cheats** | *UE4 Console Cheats* | *Quantum Console* by QFSW | *Panku Console* by Feo Wu |
| **Runtime Inspector** | *ImGui for UE* by Segkan | *Runtime Inspector* by Süleyman | *ImGui-Godot* by pkdawson |
| **Visual Debugging** | *Debug Toolkit* by JimboA | *Debug Drawing Extension* by Akien | *Debug Draw 3D* by DmitriySalnikov |

---

**The Point:**
*   Tools exist in every engine - you're not reinventing the wheel
*   The *skill* of building tools transfers across engines
*   Godot's advantage: The editor IS a Godot game. Same UI code, same nodes, zero context switch.

---

#### 6. Types of Editor Extensions (5-8 mins)

*Goal: Show the "menu" of what's possible in Godot before live-coding.*

| Type | What It Does | When To Use |
|------|--------------|-------------|
| **Toolbar Buttons** | One-click actions | Quick automation ("Reimport All", "Reset Scene") |
| **Docks & Panels** | Persistent UI alongside your work | Ongoing workflows (Sheet Editor, Scene Tree) |
| **Bottom Panels** | Tab next to Output/Debugger | Tools that need more horizontal space |
| **Inspector Plugins** | Customize property editing | Better UX for specific types (sliders, previews) |
| **Main Screen Plugins** | Replace the entire viewport | Complex editors (Tilemap, Dialogic, your Data Table) |
| **Gizmos** | 3D/2D handles in viewport | Spatial editing (Path3D, collision shapes) |
| **Importers** | Handle external file formats | Custom assets (your CSV import) |

*Transition:* "Let's build the simplest one - a toolbar button - and see how fast we can extend the editor."

---

#### 7. Live Demo: Your First Plugin (10-12 mins)

*   *Goal: Show how easy it is to start. Build something in under 5 minutes.*
*   **What We Build:** A "Bazinga!" button that we'll move around the ENTIRE editor.
*   **The Message:** *"Every corner of Godot can be extended. Let me show you WHERE."*
*   **Code Reference:** See `Presentation_GodotPlugins_TheSecretWeapon_Code.md`
*   **Plugin Location:** `addons/bazinga/` (pre-built, just enable it)

---

**Demo Flow:**
1.  Open Project Settings → Plugins → Enable "Bazinga!"
2.  Button appears in toolbar → Click it → "Bazinga!" prints to Output
3.  Open `addons/bazinga/plugin.gd` in the editor
4.  **The magic:** Uncomment different `add_control_to_*` lines to move the button
5.  Each time, disable/enable plugin to show the new location
6.  Show 2-3 locations: Toolbar → Right Dock → Bottom Panel

---

**Demo Script (what to say):**
1. *"This plugin already exists - I just need to enable it."*
2. Enable → Click → "Bazinga!" in Output
3. *"But here's the real magic - watch what happens when I change ONE line of code..."*
4. Uncomment `DOCK_SLOT_RIGHT_UL` → Disable/Enable → Button near Inspector
5. Uncomment `add_control_to_bottom_panel` → Button becomes a new tab!
6. *"Every. Single. Part. Of this editor can be extended."*
7. *"And this is just a button. Imagine what you could build."*

*Transition:* "Now let me show you what happens when you take this to its logical conclusion..."

### Part 3: The "What" - Case Study (≈30–35 Minutes)

#### 8. The Problem: Vanilla Godot Workflow (7-10 mins)

*   **The Missing Feature:** Godot has no native "Data Table" (like Unreal).
*   **The Godot Way:** We use `Resource` files. One resource = One enemy type.

**Live Demo: The Pain**
1.  **Create the Data Class:**
    *   Show `EnemyData.gd` with `@export` vars (`hp`, `damage`, `speed`, `name`)
2.  **Create Resources Manually:**
    *   Right-click → New Resource → Select script → Save as `goblin.tres`
    *   Repeat for `skeleton.tres`, `boss.tres`
    *   *Emphasize the tedium* - each requires 4-5 clicks
3.  **Edit Values:**
    *   Double-click `goblin.tres` → Inspector opens → Change HP → Save
    *   Now open `skeleton.tres` to compare... *"Wait, what was Goblin's HP again?"*
4.  **The Balancing Nightmare:**
    *   "I need to see all enemies side-by-side"
    *   *Show:* Opening 3+ Inspector windows, arranging them awkwardly
5.  **The Bulk Edit Problem:**
    *   "All enemies need +10 HP for harder difficulty"
    *   *Show:* Opening each file one by one... or editing `.tres` as text (error-prone)

**Pain Points to Verbalize:**
*   "No overview - I can't see the forest for the trees"
*   "No comparison - Is the Boss actually stronger than the Minion?"
*   "No bulk operations - 100 enemies = 100 manual edits"

**The Scaling Issue:**
*   10 Enemies = 10 Files. Manageable.
*   100 Enemies = 100 Files. Chaos.
*   1000 Items in an RPG? *Good luck.*

---

#### 9. The "Simple" Approach: Sheet Editor (8-10 mins)

*   **The Concept:** A generic spreadsheet inside Godot. The first step toward sanity.
*   **The Name:** "Sheet Editor" (Yes, say it out loud carefully. 😅)

**Live Demo: The Improvement**
1.  **Create a Sheet:** One click, name it, done.
2.  **Add Columns & Rows:** Define structure on the fly.
3.  **Enter Data:** Type directly into cells - all visible at once!
4.  **CSV Export/Import:** Works with Excel, Google Sheets, external tools.

**Features:**
*   Flexible, arbitrary tables
*   CSV imports/exports for external collaboration
*   Great for prototypes and quick data entry

**The Limitation:**
*   It's just strings. No type safety.
*   "Is `10` a number or a string?" → Runtime errors.
*   No connection to your GDScript classes.

**Transition:** *"This is better, but we're still converting strings to types manually. We need the editor to understand our code."*

---

#### 10. The Solution: Class Table Editor (12-15 mins)

*   **The Concept:** A spreadsheet-like editor *inside* Godot that understands GDScript types.
*   **The Key Insight:** Use `Script.get_script_property_list()` to read your class definition automatically.

**Live Demo: The Solution**
1.  **Same Data Class** - `EnemyData.gd` (unchanged from vanilla demo!)
2.  **Create a Class Table:**
    *   One click → Select class from dropdown → Columns auto-generated
3.  **Add Rows:**
    *   Click "Add Row" → Type values directly in cells
    *   *Show:* All enemies visible at once, proper type editors (spinbox for int, checkbox for bool, color picker for Color)
4.  **Compare & Balance:**
    *   Sort by HP column → "Ah, the Goblin is tankier than the Skeleton - that's a bug!"
    *   Fix it in 2 seconds, see the change immediately
5.  **Type Safety in Action:**
    *   Try typing `"ten"` in an integer field → Editor prevents it
    *   *"The error happens here, not at 2 AM when your build breaks."*
6.  **Runtime Usage:**
    *   Show `TableHandle.get_data(EnemyData)` - type-safe array returned
    *   No parsing, no casting, no runtime errors from bad data

**Workflow Impact:**
*   Designers edit data directly without touching code
*   Fewer runtime crashes from bad data
*   Balancing sessions that used to take hours now take minutes

**Visual Comparison Slide:**

| Task | Vanilla | With Class Table |
|------|---------|------------------|
| Create 10 enemies | ~50 clicks, 10 files | 10 rows, 1 file |
| Compare HP values | Open 10 Inspectors | One glance |
| Increase all HP by 10 | Edit 10 files manually | Select column, offset |
| Find the strongest | Mental math | Sort by column |
| Type safety | None (runtime errors) | Full (editor validation) |

**Closing Line:** *"The Godot Inspector is great for one resource. But game design isn't about one enemy - it's about the relationship between all of them. That's what we're solving."*

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

