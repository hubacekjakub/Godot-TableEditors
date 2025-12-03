# Presentation Proposal: Godot Plugins - The Editor's Secret Weapon

**Speaker:** Jakub Hubáček
**Duration:** 90 Minutes (75 min content + 15 min Q&A)
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

### Part 1: Why Tools (≈20–25 Minutes)

#### 1. Opening: Why Tools, Why Now? (4 Minutes)

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
*   **The Solo Opportunity:** Creating a game solo is hard—only a few succeed. But what about creating a tool? That's something you *can* do solo. There are even developers making a living selling paid tools and plugins.
*   **The Career Path:** Tool engineering is a real, in-demand specialization.
    *   *[TODO: Research open job postings for "Tools Engineer", "Tools Programmer", "Pipeline TD" at major studios]*
    *   *Examples to find: Ubisoft, EA, Naughty Dog, Insomniac, CD Projekt, etc.*
    *   *Key point: These roles exist at every major studio—it's not a niche.*
*   **Thesis:** Every serious project (even solo) benefits from a few well-chosen tools.

#### 2. The "I'll Just Do It Manually" Trap (8–10 mins)
*   **The Myth:** "Writing a tool takes 5 hours, doing it manually takes 5 minutes."
*   **The Reality:** You do the manual task 100 times. You make mistakes 10 times. You hate your life 100% of the time.
*   **Simple ROI Formula:**
    *   `Tool_Time < Manual_Time * N + Cost_of_Bugs`
*   **The Counterpoint:** On the other hand, you *can* make a tool for anything—but does it make sense to create a tool for it? Not every task justifies the investment.

*   **👥 AUDIENCE MOMENT – Quick Poll (hands up):**
    *   *"How many of you have a task in your current project that you do more than 10 times?"*
    *   *"More than 50 times?"*
    *   *"Keep your hand up if you hate doing it."*
    *   *"That's your first tool candidate."*

*   **The Value:**
    *   **Consistency:** Tools don't make typos.
    *   **Scalability:** Handling 10 items vs 1000 items.
    *   **Democratization:** Allowing designers/artists to tweak values without touching code.

#### 3. Tool Design Principles (8–10 mins)
*These principles apply across all engines—Godot, Unity, Unreal, and beyond.*

*   **Editor-first UX:** The tool lives where people work.
    *   *Godot:* Always-visible docks, no hidden scenes.
    *   *Unity:* Custom Editor Windows, Inspector drawers.
    *   *Unreal:* Editor Utility Widgets, Detail Customizations.
*   **Type Safety Over Clever Parsing:** Use the engine's native reflection APIs instead of regex on text files.
    *   *Godot:* `Script.get_script_property_list()`
    *   *Unity:* `SerializedProperty`, `TypeCache`
    *   *Unreal:* `UClass` reflection, `TFieldIterator`
*   **Text-based Assets:** Prefer formats that Git can diff.
    *   *Godot:* `.tres` (text resources), CSV
    *   *Unity:* Force Text Serialization for `.asset` and `.prefab`
    *   *Unreal:* JSON Data Tables, text-based config files
*   **Fail in Editor, Not at Runtime:** Validate early—yell at designers before the build breaks.
    *   All engines support editor-time validation. Use it.
*   **Small, Focused Tools:** Each tool solves one concrete pain point really well.
    *   Resist feature creep. A tool that does one thing perfectly beats a tool that does ten things poorly.

---

### Part 2: The "How" - Tools Across All Engines (≈10–15 Minutes)

*Goal for Part 2: Establish that editor customization is a universal skill across all game engines. This isn't just a Godot thing—it's an industry-wide practice. High school students exploring game dev should know this skill transfers everywhere.*

#### 4. Tools You Already Know (2-3 mins)

*Goal: Build on familiar ground—everyone has used plugins, even if they didn't think of them that way.*

*   **👥 AUDIENCE MOMENT – Quick Question:**
    *   *"Quick show of hands: Who here uses Unity? Unreal? Godot? Something else?"*
    *   *(Acknowledge the mix)* *"Perfect—what I'm about to show you applies to ALL of you."*

*   **The Revelation:** You've been using plugins all along. Let's name a few:
    *   **FMOD** – Audio middleware everyone knows. It's a plugin!
    *   **Steamworks** – Steam integration (achievements, leaderboards, matchmaking). Plugin.
    *   **Blueprints** – Unreal's visual scripting. Yes, it's a plugin you can disable.
    *   **Bolt / Visual Scripting** – Unity's visual scripting (now built-in). Started as a plugin.
    *   **Cinemachine** – Unity's camera system. Was a plugin, now built-in.
*   **The Point:** The line between "engine feature" and "plugin" is blurry. Many core features started as plugins. *You're not building something alien—you're building what engines are made of.*

---

#### 4.5. The Building Blocks: Extension APIs (2-3 mins)

*Goal: Show that every engine has the same concepts—just different syntax.*

| Engine | Core Extension Classes |
|--------|------------------------|
| **Unreal** | `Editor Utility Widget`, `Details Panel Customization`, `Blutility` |
| **Unity** | `EditorWindow`, `CustomEditor`, `GraphView` |
| **Godot** | `EditorPlugin`, `EditorInspectorPlugin`, `EditorProperty` |

*Key Insight:* The concepts map 1:1 across engines:
*   **Custom Inspector** → Unreal: Details Customization | Unity: CustomEditor | Godot: EditorInspectorPlugin
*   **Standalone Window** → Unreal: Editor Utility Widget | Unity: EditorWindow | Godot: EditorPlugin + dock
*   **Property Editor** → Unreal: FPropertyEditorModule | Unity: PropertyDrawer | Godot: EditorProperty
*   **Import Pipeline** → Unreal: Asset Actions | Unity: AssetPostprocessor | Godot: EditorImportPlugin

*The syntax changes, the concepts don't.*

---

#### 5. The Tool Ecosystem: Quick Showcase (3-4 mins)

*Goal: A rapid-fire visual tour. Screenshots speak louder than words. Show 1 slide per category, 30 seconds each.*

| Category | Unreal | Unity | Godot |
|----------|--------|-------|-------|
| **World Building** | Voxel Plugin | Cinemachine | Terrain3D |
| **Data Management** | Dialogue Plugin | Odin Inspector | Loom |
| **Visual Scripting** | Blueprints | Bolt/Visual Scripting | Orchestrator |
| **Audio** | FMOD for UE | FMOD for Unity | FMOD GDExtension |
| **Debug Consoles** | — | Quantum Console | Panku Console |

**The Takeaway (one slide):**
*   Tools exist in every engine—you're not reinventing the wheel
*   The *skill* of building tools transfers to any engine you use later
*   Godot's unique advantage: The editor IS a Godot game. Same UI code, same nodes, zero context switch.

---

#### 6. The Tool Spectrum: From Buttons to Ecosystems (3-4 mins)

*Goal: Show that tools exist on a spectrum—pick the right size for your problem.*

| Size | Examples |
|------|----------|
| **🔘 One-Button** | "Reimport All", "Format Code" |
| **📋 Panels & Docks** | Sheet Editor, Asset Browser |
| **🖥️ Full-Screen Editors** | Dialogic, Orchestrator |
| **🔍 Runtime Tools** | Panku Console, profilers |
| **🌐 External Tools** | FMOD, Spine |

*Key Insight:* The best tool is the smallest one that solves the problem. Don't overbuild.

*Transition:* "Let's build the simplest one—a toolbar button—and see how fast we can extend the editor."

---

#### 7. Live Demo: Your First Plugin (10-12 mins)

*   *Goal: Show how easy it is to start. Build something in under 5 minutes.*

*   **👥 AUDIENCE MOMENT – Prediction Game:**
    *   *"Before I show you—how many lines of code do you think it takes to add a button to Godot's toolbar?"*
    *   *"Shout it out! 100? 50? 20?"*
    *   *(After guesses)* *"Let's find out..."*

*   **What We Build:** A "Bazinga!" button that we'll move around the ENTIRE editor.
*   **The Message:** *"Every corner of Godot can be extended. Let me show you WHERE."
*   **Two Amazing Facts About Godot:**
    1.  **The Godot Editor is made in Godot.** Same `Control` nodes, same `Container` layouts, same signals. If you can build a UI in your game, you can build a plugin.
    2.  **Every piece of the editor can be replaced by a plugin.** This is both a superpower and a responsibility—you can break things if you're not careful, but you can also fix or improve *anything*.
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
6. *"Every. Single. Part. Of this editor can be extended—or replaced entirely."*
7. *"The Godot Editor is made in Godot. That's why this works. And that's amazing."*
8. *"This is just a button. Imagine what you could build."*

*Transition:* "Now let me show you what happens when you take this to its logical conclusion..."

### Part 3: The "What" - Case Study (≈25–30 Minutes)

#### 8. The Problem: Vanilla Godot Workflow (6-8 mins)

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

*   **👥 AUDIENCE MOMENT – Reality Check:**
    *   *"Raise your hand if this looks familiar—you've got data scattered across dozens of files and no easy way to see it all."*
    *   *"Keep it up if you've ever made a mistake because you couldn't compare two things side by side."*
    *   *"Yeah. That's the problem we're solving."*

---

#### 9. The "Simple" Approach: Sheet Editor (6-8 mins)

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

#### 10. The Solution: Class Table Editor (10-12 mins)

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

    *   **👥 AUDIENCE MOMENT – Spot the Bug:**
        *   *(Show the sorted table)* *"Can anyone spot a balancing problem here?"*
        *   *(Let someone call it out)* *"Exactly! That took you 2 seconds. In the old workflow, you might never notice."*

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

### Part 4: Closing (≈5 Minutes)

#### 11. Wrap-Up & Call to Action (5 mins)

**Three Takeaways:**
1.  **Tools pay for themselves.** The time you invest in building a tool comes back multiplied. Even a simple button can save hours.
2.  **The Godot Editor is made in Godot.** You already know how to build plugins—same nodes, same signals, same UI code.
3.  **Start small, solve real pain.** Don't build a framework. Build the smallest thing that removes friction from your daily workflow.

**The Industry Reality:**
*   What I see in the industry? People get *used* to being annoyed by a process. They do the same tedious thing every day and have no idea there's a better way. It becomes invisible pain.
*   But we're developers, right? We *create* stuff. We can spot that weakness and add one small button to make the job easier.
*   What happens in companies is they build a **toolkit**—a collection of small tools they reuse from project to project. Every new game starts faster because they've already solved yesterday's problems.

**Your Path Forward:**
*   **Start noticing.** When something annoys you, write it down. That's a tool waiting to be built.
*   **Start small.** One button. One automation. See how it feels.
*   **Start collecting.** Over time, you'll have your own toolkit—and that's a superpower.

**Resources:**
*   **This Presentation's Code:** `github.com/hubacekjakub/Godot-SheetEditor` (Sheet Editor, Class Table Editor, and the Bazinga demo)
*   **Godot Docs – EditorPlugin:** `docs.godotengine.org/en/stable/classes/class_editorplugin.html`
*   **Godot Asset Library:** Browse existing plugins for inspiration
*   **🤫 Secret Tip:** Look into asset stores for plugins. There's a ton of amazing stuff for $10 (without sale) that can save your team hundreds of dollars in development time. And once you buy them—you can expand on them, pick functionality from them, or just learn from their code.

**Final Slide:**
*   *"Every corner of Godot can be extended. Now you know how. Go build something."*
*   Contact info / social handles
*   *"Questions?"*

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

**Jakub Hubáček** is a developer at **Flying Rat Studio**

