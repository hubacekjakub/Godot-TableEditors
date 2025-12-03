# Godot Plugins - The Editor's Secret Weapon
## Slide-by-Slide Script

**Speaker:** Jakub Hubáček
**Duration:** 75 min + 15 min Q&A

---

## PART 1: WHY TOOLS (20-25 min)

---

### Slide 1: Title

**POINTS:**
- Godot Plugins – The Editor's Secret Weapon
- Jakub Hubáček | Flying Rat Studio

**NOTES:**
- Pause, let them read it

---

### Slide 2: Who Am I

**POINTS:**
- Developer at Flying Rat Studio
- Passionate about tools & pipelines
- *"I automate the boring stuff so we can focus on the fun stuff"*

**NOTES:**
- Keep it brief, 30 seconds max

---

### Slide 3: Agenda

**POINTS:**
- Part 1 – Why Tools Matter
- Part 2 – How to Build Them (any engine)
- Part 3 – Case Study: Data Editor in Godot

**NOTES:**
- Set expectations for the 75 minutes

---

### Slide 4: The Pain (Audience Questions)

**POINTS:**
- 👥 *"Who has broken a build because of a typo in a data file?"*
- 👥 *"Who spent an hour on repetitive work thinking 'there must be a better way'?"*
- 👥 *"Who was afraid to change a mechanic because updating data would take forever?"*

**NOTES:**
- Raise your own hand first to break the ice
- Wait for hands, acknowledge them

---

### Slide 5: Who is a Tool Developer?

**POINTS:**
- **Force Multiplier** – One dev makes the whole team faster
- **Bridge Tech & Creativity** – Clean workflows from messy problems
- **Saves 20-30%** of production time

**NOTES:**
- This is a real career path, not a side hobby
- "A single developer improves the daily work of dozens"
- "Fewer delays, fewer errors, smoother collaboration"
- Tool devs turn messy real-world problems into clean, reliable workflows
- Their innovation shapes how the entire studio makes games
- End with: "You don't need a dedicated team. Godot makes this accessible to everyone."

**VISUAL:** 📷 Photo of a studio with multiple monitors / tools in use

---

### Slide 6: The Solo Opportunity

**POINTS:**
- Making a game solo? Hard. Few succeed.
- Making a tool solo? Very doable.
- People sell plugins for a living.

**NOTES:**
- Creating a game solo is hard—only a few succeed
- But creating a tool? That's something you CAN do solo
- There are developers making a living selling paid tools and plugins
- Godot Asset Library, Unity Asset Store, Fab (Unreal)
- It's a legitimate income stream
- This is a realistic path even if the "make a hit game" path feels impossible

---

### Slide 7: The Career Path

**POINTS:**
- "Tools Engineer" is a real job title
- Every major studio has this role
- Ubisoft, EA, Naughty Dog, CD Projekt...

**NOTES:**
- Job titles: "Tools Engineer", "Tools Programmer", "Pipeline TD"
- These roles exist at EVERY major studio—it's not a niche
- Key point: This is a real, in-demand specialization
- Thesis to land: "Every serious project (even solo) benefits from a few well-chosen tools"
- [TODO: Add 2-3 actual job posting screenshots]

---

### Slide 8: The Manual Trap

**POINTS:**
- Myth: *"Tool = 5 hours. Manual = 5 minutes."*
- Reality: You do it 100 times. Mistakes happen 10 times.
- Formula: `Tool_Time < Manual_Time × N + Bug_Cost`

**NOTES:**
- The myth: "Writing a tool takes 5 hours, doing it manually takes 5 minutes"
- The reality: You do the manual task 100 times. You make mistakes 10 times. You hate your life 100% of the time.
- BUT—counterpoint: You CAN make a tool for anything, but does it make sense? Not every task justifies the investment.
- The ROI is almost always there for repetitive tasks

---

### Slide 9: Audience Poll

**POINTS:**
- 👥 *"Hands up: task you do 10+ times?"*
- 👥 *"50+ times?"*
- 👥 *"Keep it up if you hate doing it."*
- *"That's your first tool candidate."*

**NOTES:**
- Pause between each question
- Make eye contact with people with hands up

---

### Slide 10: The Value of Tools

**POINTS:**
- **Consistency** – Tools don't make typos
- **Scalability** – 10 items or 1000 items, same effort
- **Democratization** – Designers edit values, no code needed

**NOTES:**
- Consistency: A tool will never misspell "skeleton" as "skelton"
- Scalability: The same tool that handles 10 enemies handles 1000—no extra work
- Democratization: Designers and artists can tweak values without touching code—huge for team velocity
- These benefits compound over time—the longer you use a tool, the more it pays off

---

### Slide 11: Principle 1 – Editor-First UX

**POINTS:**
- The tool lives where people work
- Godot: Docks, bottom panels
- Unity: Editor Windows, Inspector
- Unreal: Editor Utility Widgets

**NOTES:**
- Don't hide your tool in a separate scene
- In Godot: Always-visible docks, no hidden scenes
- The tool should be one click away, not buried in menus
- If people have to hunt for it, they won't use it

**VISUAL:** 📷 Screenshot of a dock in Godot

---

### Slide 12: Principle 3 – Fail Early

**POINTS:**
- Validate in editor, not at runtime
- Yell at designers before the build breaks
- Catch bugs at 2 PM, not 2 AM

**NOTES:**
- "Fail in Editor, Not at Runtime"
- If a designer enters bad data, tell them NOW—not when the game crashes at 2 AM
- All engines support editor-time validation—use it!
- The error should happen the moment they type something wrong
- Editor-time validation = fewer fire drills, fewer emergency fixes

---

### Slide 13: Principle 4 – Small & Focused

**POINTS:**
- One tool = one problem solved well
- Resist feature creep
- A button that works > a panel nobody uses

**NOTES:**
- "Small, Focused Tools"
- Each tool solves ONE concrete pain point really well
- Resist feature creep—it's tempting to add "just one more thing"
- A tool that does one thing perfectly beats a tool that does ten things poorly
- You can always add more features later—ship the simple version first

---

## PART 2: THE HOW (10-15 min)

---

### Slide 14: Part 2 Intro

**POINTS:**
- This skill transfers to ANY engine
- Not just Godot – Unity, Unreal, all of them
- 👥 *"Show of hands: Unity? Unreal? Godot? Other?"*

**NOTES:**
- Acknowledge the mix, then say "This applies to ALL of you"

---

### Slide 15: Plugins You Already Use

**POINTS:**
- FMOD – Plugin!
- Steamworks – Plugin!
- Blueprints – Plugin (you can disable it)
- Cinemachine – Started as a plugin

**NOTES:**
- "You've been using plugins all along"
- FMOD – Audio middleware everyone knows. It's a plugin!
- Steamworks – Steam integration (achievements, leaderboards). Plugin.
- Blueprints – Unreal's visual scripting. Yes, it's a plugin you can disable!
- Bolt / Visual Scripting – Unity's visual scripting. Started as a third-party plugin.
- Cinemachine – Unity's camera system. Was a plugin, now built-in.
- The point: The line between "engine feature" and "plugin" is blurry
- Many core features started as plugins
- "You're not building something alien—you're building what engines are made of"

---

### Slide 16: The Building Blocks

**POINTS:**
| Concept | Unreal | Unity | Godot |
|---------|--------|-------|-------|
| Custom Inspector | Details Customization | CustomEditor | EditorInspectorPlugin |
| Standalone Window | Editor Utility Widget | EditorWindow | EditorPlugin + dock |
| Property Editor | FPropertyEditorModule | PropertyDrawer | EditorProperty |

**NOTES:**
- "The concepts map 1:1 across engines"
- Same concepts, different syntax
- Also: Import Pipeline → Unreal: Asset Actions | Unity: AssetPostprocessor | Godot: EditorImportPlugin
- The syntax changes, the concepts don't
- If you learn this in one engine, you can do it in any engine

---

### Slide 17: Tool Showcase – World Building

**POINTS:**
- Unreal: Voxel Plugin
- Unity: Cinemachine
- Godot: Terrain3D

**NOTES:**
- 30 seconds, let the screenshots speak

**VISUAL:** 📷 Screenshot grid of all three

---

### Slide 18: Tool Showcase – Visual Scripting

**POINTS:**
- Unreal: Blueprints
- Unity: Bolt / Visual Scripting
- Godot: Orchestrator

**VISUAL:** 📷 Screenshot grid of all three

---

### Slide 19: Tool Showcase – Audio

**POINTS:**
- FMOD exists for all three engines
- Some tools live OUTSIDE the engine

**VISUAL:** 📷 FMOD Studio screenshot

---

### Slide 20: Tool Showcase – Debug Consoles

**POINTS:**
- Unity: Quantum Console
- Godot: Panku Console

**VISUAL:** 📷 Screenshot of both

---

### Slide 21: The Takeaway

**POINTS:**
- Tools exist in every engine
- The skill transfers everywhere
- Godot bonus: The editor IS a Godot game

**NOTES:**
- Tools exist in every engine—you're not reinventing the wheel
- The SKILL of building tools transfers to any engine you use later
- Godot's unique advantage: The editor IS a Godot game
- Same UI code, same nodes, zero context switch
- If you can build a game UI, you can build an editor plugin

---

### Slide 22: The Tool Spectrum

**POINTS:**
| Size | Examples |
|------|----------|
| 🔘 One-Button | "Reimport All" |
| 📋 Panel/Dock | Sheet Editor |
| 🖥️ Full Editor | Dialogic |
| 🔍 Runtime | Panku Console |
| 🌐 External | FMOD |

**NOTES:**
- Pick the right size for your problem
- Don't overbuild—a button that saves 10 clicks is worth more than a fancy panel no one uses
- The best tool is the smallest one that solves the problem
- You can always grow it later if needed
- Transition: "Let's build the simplest one—a toolbar button—and see how fast we can extend the editor."

---

### Slide 23: Live Demo Intro

**POINTS:**
- 👥 *"How many lines to add a toolbar button?"*
- *"Shout it out! 100? 50? 20?"*

**NOTES:**
- Build anticipation before the demo
- Wait for guesses—engage with their answers
- After guesses: "Let's find out..."
- The answer will surprise them (it's very few lines)

---

### Slide 24: LIVE DEMO – Bazinga!

**POINTS:**
- Enable plugin → Click button → "Bazinga!" in Output
- Change ONE line → Button moves
- Toolbar → Dock → Bottom Panel

**NOTES:**
- Demo script:
  1. "This plugin already exists—I just need to enable it."
  2. Enable → Click → "Bazinga!" in Output
  3. "But here's the real magic—watch what happens when I change ONE line of code..."
  4. Uncomment `DOCK_SLOT_RIGHT_UL` → Disable/Enable → Button near Inspector
  5. Uncomment `add_control_to_bottom_panel` → Button becomes a new tab!
  6. "Every. Single. Part. Of this editor can be extended—or replaced entirely."
  7. "The Godot Editor is made in Godot. That's why this works. And that's amazing."
  8. "This is just a button. Imagine what you could build."
- If demo fails: Have video backup ready!
- Plugin location: `addons/bazinga/`

**VISUAL:** 🎬 Live demo (backup: video recording)

---

### Slide 25: Two Amazing Facts

**POINTS:**
1. The Godot Editor is made IN Godot
2. Every piece can be replaced by a plugin

**NOTES:**
- Fact 1: Same `Control` nodes, same `Container` layouts, same signals
- If you can build a UI in your game, you can build a plugin
- Fact 2: This is both a superpower and a responsibility
- You can break things if you're not careful, but you can also fix or improve ANYTHING
- Transition: "Now let me show you what happens when you take this to its logical conclusion..."

---

## PART 3: CASE STUDY (25-30 min)

---

### Slide 26: The Problem

**POINTS:**
- Godot has no native "Data Table" (unlike Unreal)
- We use Resources: 1 file = 1 enemy
- Pain: No overview, no comparison, no bulk edits

**NOTES:**
- "The Missing Feature": Godot has no native Data Table like Unreal
- "The Godot Way": We use Resource files. One resource = One enemy type.
- This is fine for small projects, but it doesn't scale
- Pain points to mention:
  - "No overview—I can't see the forest for the trees"
  - "No comparison—Is the Boss actually stronger than the Minion?"
  - "No bulk operations—100 enemies = 100 manual edits"

**VISUAL:** 📷 Screenshot of FileSystem with 20 .tres files

---

### Slide 27: LIVE DEMO – The Pain

**POINTS:**
- Create `goblin.tres`, `skeleton.tres`, `boss.tres`
- Try to compare HP values...
- *"Wait, what was Goblin's HP again?"*

**NOTES:**
- Demo steps:
  1. Show `EnemyData.gd` with `@export` vars (hp, damage, speed, name)
  2. Right-click → New Resource → Select script → Save as `goblin.tres`
  3. Repeat for skeleton, boss—EMPHASIZE THE TEDIUM (4-5 clicks each!)
  4. Double-click `goblin.tres` → Inspector opens → Change HP → Save
  5. Now open `skeleton.tres` to compare... "Wait, what was Goblin's HP again?"
  6. Show: Opening 3+ Inspector windows, arranging them awkwardly
  7. "All enemies need +10 HP for harder difficulty"—show opening each file one by one
- Really ham up the frustration here—this is the "before" photo

**VISUAL:** 🎬 Live demo

---

### Slide 28: The Scaling Issue

**POINTS:**
- 10 enemies = 10 files. OK.
- 100 enemies = 100 files. Chaos.
- 1000 items in an RPG? Good luck.

**NOTES:**
- This is where it gets real
- 10 enemies, 10 files—manageable
- 100 enemies, 100 files—chaos
- 1000 items in an RPG? Good luck.
- Let this sink in—pause for effect

---

### Slide 29: Audience Reality Check

**POINTS:**
- 👥 *"Hands up if this looks familiar"*
- 👥 *"Keep it up if you've made a mistake from not comparing"*
- *"That's what we're solving."*

---

### Slide 30: Solution 1 – Sheet Editor

**POINTS:**
- Generic spreadsheet inside Godot
- Add columns/rows on the fly
- CSV import/export

**NOTES:**
- "The first step toward sanity"
- The name: "Sheet Editor" (yes, say it out loud carefully 😅)
- Features:
  - Flexible, arbitrary tables
  - CSV imports/exports for external collaboration
  - Great for prototypes and quick data entry
  - Works with Excel, Google Sheets

**VISUAL:** 📷 Screenshot of Sheet Editor

---

### Slide 31: LIVE DEMO – Sheet Editor

**POINTS:**
- Create a sheet → Add rows → Enter data
- Everything visible at once!
- Export to CSV → Edit in Excel → Import back

**NOTES:**
- Demo steps:
  1. Create a Sheet—one click, name it, done
  2. Add Columns & Rows—define structure on the fly
  3. Enter Data—type directly into cells, all visible at once!
  4. CSV Export/Import—show it works with external tools
- Emphasize: "Now I can see everything at once!"

**VISUAL:** 🎬 Live demo

---

### Slide 32: Sheet Editor Limitation

**POINTS:**
- It's all strings
- `"10"` – number or text?
- No connection to GDScript classes

**NOTES:**
- "The Limitation"—be honest about what it can't do
- It's just strings. No type safety.
- "Is `10` a number or a string?" → Runtime errors
- No connection to your GDScript classes
- Transition: "This is better, but we're still converting strings to types manually. We need the editor to understand our code."

---

### Slide 33: Solution 2 – Class Table Editor

**POINTS:**
- Spreadsheet that understands GDScript types
- Uses `Script.get_script_property_list()`
- Auto-generates columns from your class

**NOTES:**
- "The Key Insight": Use `Script.get_script_property_list()` to read your class definition automatically
- No manual column setup—it reads your code!
- Proper type editors: spinbox for int, checkbox for bool, color picker for Color
- This is the magic of native reflection APIs

**VISUAL:** 📷 Screenshot of Class Table Editor

---

### Slide 34: LIVE DEMO – Class Table

**POINTS:**
- Same `EnemyData.gd` – unchanged!
- Select class → Columns appear
- Proper editors: spinbox, checkbox, color picker

**NOTES:**
- Demo steps:
  1. Same Data Class—`EnemyData.gd` (unchanged from vanilla demo!)
  2. Create a Class Table—one click → select class from dropdown → columns auto-generated
  3. Add Rows—click "Add Row" → type values directly in cells
  4. Show: All enemies visible at once, proper type editors
- Emphasize: "Same class file, zero changes—the tool figures it out"

**VISUAL:** 🎬 Live demo

---

### Slide 35: Audience – Spot the Bug

**POINTS:**
- *(Show sorted table)*
- 👥 *"Can anyone spot a balancing problem?"*
- *"That took 2 seconds. Old workflow? Never noticed."*

**NOTES:**
- Sort by HP column first
- "Ah, the Goblin is tankier than the Skeleton—that's a bug!"
- Let someone in the audience call it out
- "Exactly! That took you 2 seconds. In the old workflow, you might never notice."
- Fix it live in 2 seconds—show how immediate the change is

---

### Slide 36: Type Safety Demo

**POINTS:**
- Type `"ten"` in an integer field
- Editor prevents it
- *"Error at 2 PM, not 2 AM"*

**NOTES:**
- Type Safety in Action:
- Try typing `"ten"` in an integer field → Editor prevents it
- "The error happens HERE, not at 2 AM when your build breaks."
- This is why native type editors matter—can't enter invalid data
- Runtime Usage: Show `TableHandle.get_data(EnemyData)` – type-safe array returned
- No parsing, no casting, no runtime errors from bad data

**VISUAL:** 🎬 Live demo / GIF

---

### Slide 37: The Comparison

**POINTS:**
| Task | Vanilla | Class Table |
|------|---------|-------------|
| Create 10 enemies | ~50 clicks | 10 rows |
| Compare HP | 10 Inspectors | One glance |
| +10 HP to all | Edit 10 files | Column offset |
| Type safety | None | Full |

**NOTES:**
- Let this table sink in—dramatic difference
- "Find the strongest" = mental math vs sort by column
- Workflow Impact:
  - Designers edit data directly without touching code
  - Fewer runtime crashes from bad data
  - Balancing sessions that used to take hours now take minutes

---

### Slide 38: Case Study Closing

**POINTS:**
- *"The Inspector is great for ONE resource."*
- *"Game design is about relationships between ALL of them."*
- *"That's what this solves."*

**NOTES:**
- This is the key insight—let it land
- Pause after each line
- The Godot Inspector is excellent for editing one thing
- But game design isn't about one enemy—it's about the relationship between all of them
- That's the gap we're filling

---

## PART 4: CLOSING (5 min)

---

### Slide 39: Three Takeaways

**POINTS:**
1. Tools pay for themselves
2. The Godot Editor is made in Godot
3. Start small, solve real pain

**NOTES:**
- 1. "The time you invest in building a tool comes back multiplied. Even a simple button can save hours."
- 2. "You already know how to build plugins—same nodes, same signals, same UI code."
- 3. "Don't build a framework. Build the smallest thing that removes friction from your daily workflow."

---

### Slide 40: Industry Reality

**POINTS:**
- People get USED to being annoyed
- Invisible pain – they don't know there's a better way
- We're developers. We CREATE stuff. We can fix this.

**NOTES:**
- "What I see in the industry? People get USED to being annoyed by a process."
- "They do the same tedious thing every day and have no idea there's a better way."
- "It becomes invisible pain."
- "But we're developers, right? We CREATE stuff."
- "We can spot that weakness and add one small button to make the job easier."

---

### Slide 41: The Toolkit

**POINTS:**
- Companies build toolkits they reuse
- Every project starts faster
- Your toolkit = your superpower

**NOTES:**
- "What happens in companies is they build a TOOLKIT"
- "A collection of small tools they reuse from project to project"
- "Every new game starts faster because they've already solved yesterday's problems"
- "Over time, you'll have your own toolkit—and that's a superpower"

---

### Slide 42: Your Path

**POINTS:**
- **Notice** – When annoyed, write it down
- **Start small** – One button
- **Collect** – Build your toolkit over time

**NOTES:**
- "Start noticing. When something annoys you, write it down. That's a tool waiting to be built."
- "Start small. One button. One automation. See how it feels."
- "Start collecting. Over time, you'll have your own toolkit."

---

### Slide 43: Resources

**POINTS:**
- Code: `github.com/hubacekjakub/Godot-SheetEditor`
- Docs: `docs.godotengine.org` → EditorPlugin
- Godot Asset Library

**NOTES:**
- All the code from this presentation is available
- Sheet Editor, Class Table Editor, and the Bazinga demo
- Godot docs have excellent EditorPlugin documentation
- Asset Library—browse existing plugins for inspiration

---

### Slide 44: Secret Tip

**POINTS:**
- 🤫 Look into asset stores
- $10 plugin → saves hundreds in dev time
- Buy → Expand → Learn from code

**NOTES:**
- This is insider knowledge—lean in conspiratorially
- "There's a ton of amazing stuff for $10 (without sale)"
- "That can save your team hundreds of dollars in development time"
- "And once you buy them—you can expand on them, pick functionality from them, or just learn from their code"
- It's like buying a tutorial that actually works

---

### Slide 45: Final Slide

**POINTS:**
- *"Every corner of Godot can be extended."*
- *"Now you know how."*
- *"Go build something."*

**NOTES:**
- Say each line slowly, with weight
- Pause between lines
- This is the moment—let it land
- Then smile and move to Q&A

---

### Slide 46: Questions?

**POINTS:**
- Contact info / social handles
- *"Questions?"*

**NOTES:**
- 15 minutes for Q&A
- If no questions immediately, have a backup: "One question I often get is..."
- Possible backup questions:
  - "How long did it take to build the Class Table Editor?" → Answer honestly
  - "What's the hardest part of building plugins?" → Testing, edge cases
  - "Where do I start?" → Enable Bazinga, read the code, modify it

---

## SLIDE COUNT SUMMARY

| Part | Slides |
|------|--------|
| Part 1: Why Tools | 13 slides |
| Part 2: The How | 12 slides |
| Part 3: Case Study | 13 slides |
| Part 4: Closing | 8 slides |
| **Total** | **46 slides** |

---

## VISUAL ASSETS NEEDED

- [ ] Studio photo with tools (Slide 5)
- [ ] Job posting screenshots (Slide 7)
- [ ] Godot dock screenshot (Slide 11)
- [ ] Tool showcase grids – 3 categories (Slides 17-20)
- [ ] Panku Console screenshot (Slide 20)
- [ ] FileSystem with many .tres files (Slide 26)
- [ ] Sheet Editor screenshot (Slide 30)
- [ ] Class Table Editor screenshot (Slide 33)
- [ ] Type safety error GIF (Slide 36)
- [ ] Backup demo videos for all live demos
