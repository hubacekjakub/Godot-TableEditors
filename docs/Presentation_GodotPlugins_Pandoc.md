---
title: Godot Plugins - The Editor's Secret Weapon
author: Jakub Hubáček | Flying Rat Studio
---

# Godot Plugins

## The Editor's Secret Weapon

**Jakub Hubáček** | Flying Rat Studio

::: notes
Pause, let them read it
:::

---

# Who Am I

- Developer at **Flying Rat Studio**
- Passionate about tools & pipelines
- *"I automate the boring stuff so we can focus on the fun stuff"*

::: notes
Keep it brief, 30 seconds max
:::

---

# Agenda

- **Part 1** – Why Tools Matter
- **Part 2** – How to Build Them (any engine)
- **Part 3** – Case Study: Data Editor in Godot

::: notes
Set expectations for the 75 minutes
:::

---

# The Pain

👥 *"Who has broken a build because of a typo in a data file?"*

👥 *"Who spent an hour on repetitive work thinking 'there must be a better way'?"*

👥 *"Who was afraid to change a mechanic because updating data would take forever?"*

::: notes
Raise your own hand first to break the ice
Wait for hands, acknowledge them
:::

---

# Who is a Tool Developer?

- **Force Multiplier** – One dev makes the whole team faster
- **Bridge Tech & Creativity** – Clean workflows from messy problems
- **Saves 20-30%** of production time

*"You don't need a dedicated team. Godot makes this accessible to everyone."*

::: notes
This is a real career path, not a side hobby.
"A single developer improves the daily work of dozens"
"Fewer delays, fewer errors, smoother collaboration"
Tool devs turn messy real-world problems into clean, reliable workflows.
Their innovation shapes how the entire studio makes games.
:::

---

# The Solo Opportunity

- Making a game solo? **Hard.** Few succeed.
- Making a tool solo? **Very doable.**
- People sell plugins for a living.

Godot Asset Library • Unity Asset Store • Fab (Unreal)

::: notes
Creating a game solo is hard—only a few succeed.
But creating a tool? That's something you CAN do solo.
There are developers making a living selling paid tools and plugins.
It's a legitimate income stream.
This is a realistic path even if the "make a hit game" path feels impossible.
:::

---

# The Career Path

**"Tools Engineer"** is a real job title

Every major studio has this role:
Ubisoft • EA • Naughty Dog • CD Projekt...

*"Every serious project benefits from a few well-chosen tools"*

::: notes
Job titles: "Tools Engineer", "Tools Programmer", "Pipeline TD"
These roles exist at EVERY major studio—it's not a niche.
Key point: This is a real, in-demand specialization.
:::

---

# The Manual Trap

**Myth:** *"Tool = 5 hours. Manual = 5 minutes."*

**Reality:** You do it 100 times. Mistakes happen 10 times.

**Formula:** `Tool_Time < Manual_Time × N + Bug_Cost`

::: notes
The myth: "Writing a tool takes 5 hours, doing it manually takes 5 minutes"
The reality: You do the manual task 100 times. You make mistakes 10 times. You hate your life 100% of the time.
BUT—counterpoint: You CAN make a tool for anything, but does it make sense? Not every task justifies the investment.
The ROI is almost always there for repetitive tasks.
:::

---

# Audience Poll

👥 *"Hands up: task you do 10+ times?"*

👥 *"50+ times?"*

👥 *"Keep it up if you hate doing it."*

**That's your first tool candidate.**

::: notes
Pause between each question.
Make eye contact with people with hands up.
:::

---

# The Value of Tools

**Consistency** – Tools don't make typos

**Scalability** – 10 items or 1000 items, same effort

**Democratization** – Designers edit values, no code needed

::: notes
Consistency: A tool will never misspell "skeleton" as "skelton"
Scalability: The same tool that handles 10 enemies handles 1000—no extra work.
Democratization: Designers and artists can tweak values without touching code—huge for team velocity.
These benefits compound over time—the longer you use a tool, the more it pays off.
:::

---

# Principle 1 – Editor-First UX

The tool lives where people work

**Godot:** Docks, bottom panels

**Unity:** Editor Windows, Inspector

**Unreal:** Editor Utility Widgets

*If people have to hunt for it, they won't use it*

::: notes
Don't hide your tool in a separate scene.
In Godot: Always-visible docks, no hidden scenes.
The tool should be one click away, not buried in menus.
:::

---

# Principle 2 – Fail Early

- Validate in editor, not at runtime
- Yell at designers before the build breaks
- **Catch bugs at 2 PM, not 2 AM**

::: notes
"Fail in Editor, Not at Runtime"
If a designer enters bad data, tell them NOW—not when the game crashes at 2 AM.
All engines support editor-time validation—use it!
The error should happen the moment they type something wrong.
:::

---

# Principle 3 – Small & Focused

- One tool = one problem solved well
- Resist feature creep
- **A button that works > a panel nobody uses**

::: notes
"Small, Focused Tools"
Each tool solves ONE concrete pain point really well.
Resist feature creep—it's tempting to add "just one more thing"
A tool that does one thing perfectly beats a tool that does ten things poorly.
You can always add more features later—ship the simple version first.
:::

---

# PART 2: The How (Any Engine)

---

# This Skill Transfers

👥 *"Show of hands: Unity? Unreal? Godot? Other?"*

This applies to **ALL** of you.

::: notes
Acknowledge the mix, then say "This applies to ALL of you"
:::

---

# Plugins You Already Use

- **FMOD** – Plugin!
- **Steamworks** – Plugin!
- **Blueprints** – Plugin (you can disable it)
- **Cinemachine** – Started as a plugin

*"You're not building something alien—you're building what engines are made of"*

::: notes
"You've been using plugins all along"
The point: The line between "engine feature" and "plugin" is blurry.
Many core features started as plugins.
:::

---

# The Building Blocks

**Custom Inspector**

Unreal: Details Customization → Unity: CustomEditor → Godot: EditorInspectorPlugin

**Standalone Window**

Unreal: Editor Utility Widget → Unity: EditorWindow → Godot: EditorPlugin + dock

**Property Editor**

Unreal: FPropertyEditorModule → Unity: PropertyDrawer → Godot: EditorProperty

*Same concepts, different syntax*

::: notes
"The concepts map 1:1 across engines"
The syntax changes, the concepts don't.
If you learn this in one engine, you can do it in any engine.
:::

---

# Tool Showcase – World Building

**Unreal:** Voxel Plugin

**Unity:** Cinemachine

**Godot:** Terrain3D

::: notes
30 seconds, let the screenshots speak
:::

---

# Tool Showcase – Visual Scripting

**Unreal:** Blueprints

**Unity:** Bolt / Visual Scripting

**Godot:** Orchestrator

---

# Tool Showcase – Audio

**FMOD** exists for all three engines

Some tools live **OUTSIDE** the engine

---

# Tool Showcase – Debug Consoles

**Unity:** Quantum Console

**Godot:** Panku Console

---

# The Takeaway

- Tools exist in **every engine**
- The skill **transfers everywhere**
- **Godot bonus:** The editor IS a Godot game

*If you can build a game UI, you can build an editor plugin*

::: notes
Tools exist in every engine—you're not reinventing the wheel.
The SKILL of building tools transfers to any engine you use later.
Godot's unique advantage: The editor IS a Godot game.
Same UI code, same nodes, zero context switch.
:::

---

# The Tool Spectrum

🔘 **One-Button** → "Reimport All"

📋 **Panel/Dock** → Sheet Editor

🖥️ **Full Editor** → Dialogic

🔍 **Runtime** → Panku Console

🌐 **External** → FMOD

*Pick the right size for your problem*

::: notes
Don't overbuild—a button that saves 10 clicks is worth more than a fancy panel no one uses.
The best tool is the smallest one that solves the problem.
You can always grow it later if needed.
:::

---

# Live Demo Time!

👥 *"How many lines to add a toolbar button?"*

*"Shout it out! 100? 50? 20?"*

::: notes
Build anticipation before the demo.
Wait for guesses—engage with their answers.
After guesses: "Let's find out..."
The answer will surprise them (it's very few lines).
:::

---

# LIVE DEMO – Bazinga!

1. Enable plugin → Click button → "Bazinga!"
2. Change **ONE line** → Button moves
3. Toolbar → Dock → Bottom Panel

*"Every. Single. Part. Of this editor can be extended."*

::: notes
Demo script:
1. "This plugin already exists—I just need to enable it."
2. Enable → Click → "Bazinga!" in Output
3. "But here's the real magic—watch what happens when I change ONE line of code..."
4. Uncomment DOCK_SLOT_RIGHT_UL → Disable/Enable → Button near Inspector
5. Uncomment add_control_to_bottom_panel → Button becomes a new tab!
6. "The Godot Editor is made in Godot. That's why this works. And that's amazing."
If demo fails: Have video backup ready!
:::

---

# Two Amazing Facts

## 1. The Godot Editor is made IN Godot

Same `Control` nodes, same `Container` layouts, same signals

## 2. Every piece can be replaced by a plugin

This is both a superpower and a responsibility

::: notes
Fact 1: Same Control nodes, same Container layouts, same signals.
If you can build a UI in your game, you can build a plugin.
Fact 2: This is both a superpower and a responsibility.
You can break things if you're not careful, but you can also fix or improve ANYTHING.
:::

---

# PART 3: Case Study: Data Editor

---

# The Problem

- Godot has **no native "Data Table"** (unlike Unreal)
- We use Resources: **1 file = 1 enemy**
- Pain: No overview, no comparison, no bulk edits

::: notes
"The Missing Feature": Godot has no native Data Table like Unreal.
"The Godot Way": We use Resource files. One resource = One enemy type.
This is fine for small projects, but it doesn't scale.
Pain points:
- "No overview—I can't see the forest for the trees"
- "No comparison—Is the Boss actually stronger than the Minion?"
- "No bulk operations—100 enemies = 100 manual edits"
:::

---

# LIVE DEMO – The Pain

1. Create `goblin.tres`, `skeleton.tres`, `boss.tres`
2. Try to compare HP values...
3. *"Wait, what was Goblin's HP again?"*

::: notes
Demo steps:
1. Show EnemyData.gd with @export vars (hp, damage, speed, name)
2. Right-click → New Resource → Select script → Save as goblin.tres
3. Repeat for skeleton, boss—EMPHASIZE THE TEDIUM (4-5 clicks each!)
4. Double-click goblin.tres → Inspector opens → Change HP → Save
5. Now open skeleton.tres to compare... "Wait, what was Goblin's HP again?"
6. Show: Opening 3+ Inspector windows, arranging them awkwardly
Really ham up the frustration here—this is the "before" photo.
:::

---

# The Scaling Issue

**10 enemies** = 10 files. OK.

**100 enemies** = 100 files. Chaos.

**1000 items** in an RPG? Good luck.

::: notes
This is where it gets real.
Let this sink in—pause for effect.
:::

---

# Audience Reality Check

👥 *"Hands up if this looks familiar"*

👥 *"Keep it up if you've made a mistake from not comparing"*

**That's what we're solving.**

---

# Solution 1 – Sheet Editor

- Generic spreadsheet inside Godot
- Add columns/rows on the fly
- CSV import/export

*Works with Excel, Google Sheets*

::: notes
"The first step toward sanity"
Features:
- Flexible, arbitrary tables
- CSV imports/exports for external collaboration
- Great for prototypes and quick data entry
:::

---

# LIVE DEMO – Sheet Editor

1. Create a sheet → Add rows → Enter data
2. Everything visible at once!
3. Export to CSV → Edit in Excel → Import back

::: notes
Demo steps:
1. Create a Sheet—one click, name it, done
2. Add Columns & Rows—define structure on the fly
3. Enter Data—type directly into cells, all visible at once!
4. CSV Export/Import—show it works with external tools
Emphasize: "Now I can see everything at once!"
:::

---

# Sheet Editor Limitation

- It's all **strings**
- `"10"` – number or text?
- No connection to GDScript classes

*We need the editor to understand our code*

::: notes
"The Limitation"—be honest about what it can't do.
It's just strings. No type safety.
"Is 10 a number or a string?" → Runtime errors.
No connection to your GDScript classes.
Transition: "This is better, but we're still converting strings to types manually."
:::

---

# Solution 2 – Class Table Editor

- Spreadsheet that understands **GDScript types**
- Uses `Script.get_script_property_list()`
- Auto-generates columns from your class

::: notes
"The Key Insight": Use Script.get_script_property_list() to read your class definition automatically.
No manual column setup—it reads your code!
Proper type editors: spinbox for int, checkbox for bool, color picker for Color.
This is the magic of native reflection APIs.
:::

---

# LIVE DEMO – Class Table

1. Same `EnemyData.gd` – **unchanged!**
2. Select class → Columns appear
3. Proper editors: spinbox, checkbox, color picker

*"Same class file, zero changes—the tool figures it out"*

::: notes
Demo steps:
1. Same Data Class—EnemyData.gd (unchanged from vanilla demo!)
2. Create a Class Table—one click → select class from dropdown → columns auto-generated
3. Add Rows—click "Add Row" → type values directly in cells
4. Show: All enemies visible at once, proper type editors
Emphasize: "Same class file, zero changes—the tool figures it out"
:::

---

# Audience – Spot the Bug

*(Sorted table displayed)*

👥 *"Can anyone spot a balancing problem?"*

*"That took 2 seconds. Old workflow? Never noticed."*

::: notes
Sort by HP column first.
"Ah, the Goblin is tankier than the Skeleton—that's a bug!"
Let someone in the audience call it out.
"Exactly! That took you 2 seconds. In the old workflow, you might never notice."
Fix it live in 2 seconds—show how immediate the change is.
:::

---

# Type Safety Demo

- Type `"ten"` in an integer field
- Editor **prevents it**
- *"Error at 2 PM, not 2 AM"*

::: notes
Type Safety in Action:
Try typing "ten" in an integer field → Editor prevents it.
"The error happens HERE, not at 2 AM when your build breaks."
This is why native type editors matter—can't enter invalid data.
Runtime Usage: Show TableHandle.get_data(EnemyData) – type-safe array returned.
:::

---

# The Comparison

**Create 10 enemies**

Vanilla: ~50 clicks → Class Table: 10 rows

**Compare HP values**

Vanilla: 10 Inspectors → Class Table: One glance

**+10 HP to all enemies**

Vanilla: Edit 10 files → Class Table: Column offset

**Type safety**

Vanilla: None → Class Table: Full

::: notes
Let this comparison sink in—dramatic difference.
"Find the strongest" = mental math vs sort by column.
Workflow Impact:
- Designers edit data directly without touching code
- Fewer runtime crashes from bad data
- Balancing sessions that used to take hours now take minutes
:::

---

# Case Study Closing

*"The Inspector is great for ONE resource."*

*"Game design is about relationships between ALL of them."*

**That's what this solves.**

::: notes
This is the key insight—let it land.
Pause after each line.
The Godot Inspector is excellent for editing one thing.
But game design isn't about one enemy—it's about the relationship between all of them.
That's the gap we're filling.
:::

---

# PART 4: Closing

---

# Three Takeaways

1. **Tools pay for themselves**
2. **The Godot Editor is made in Godot**
3. **Start small, solve real pain**

::: notes
1. "The time you invest in building a tool comes back multiplied. Even a simple button can save hours."
2. "You already know how to build plugins—same nodes, same signals, same UI code."
3. "Don't build a framework. Build the smallest thing that removes friction from your daily workflow."
:::

---

# Industry Reality

- People get **USED** to being annoyed
- **Invisible pain** – they don't know there's a better way
- We're developers. We **CREATE** stuff.
- **We can fix this.**

::: notes
"What I see in the industry? People get USED to being annoyed by a process."
"They do the same tedious thing every day and have no idea there's a better way."
"It becomes invisible pain."
"But we're developers, right? We CREATE stuff."
"We can spot that weakness and add one small button to make the job easier."
:::

---

# The Toolkit

- Companies build **toolkits** they reuse
- Every project starts faster
- **Your toolkit = your superpower**

::: notes
"What happens in companies is they build a TOOLKIT"
"A collection of small tools they reuse from project to project"
"Every new game starts faster because they've already solved yesterday's problems"
"Over time, you'll have your own toolkit—and that's a superpower"
:::

---

# Your Path

**Notice** – When annoyed, write it down

**Start small** – One button

**Collect** – Build your toolkit over time

::: notes
"Start noticing. When something annoys you, write it down. That's a tool waiting to be built."
"Start small. One button. One automation. See how it feels."
"Start collecting. Over time, you'll have your own toolkit."
:::

---

# Resources

- **Code:** `github.com/hubacekjakub/Godot-SheetEditor`
- **Docs:** `docs.godotengine.org` → EditorPlugin
- **Godot Asset Library**

::: notes
All the code from this presentation is available.
Sheet Editor, Class Table Editor, and the Bazinga demo.
Godot docs have excellent EditorPlugin documentation.
Asset Library—browse existing plugins for inspiration.
:::

---

# 🤫 Secret Tip

- Look into **asset stores**
- $10 plugin → saves hundreds in dev time
- **Buy → Expand → Learn from code**

*It's like buying a tutorial that actually works*

::: notes
This is insider knowledge—lean in conspiratorially.
"There's a ton of amazing stuff for $10 (without sale)"
"That can save your team hundreds of dollars in development time"
"And once you buy them—you can expand on them, pick functionality from them, or just learn from their code"
:::

---

# Final Words

*"Every corner of Godot can be extended."*

*"Now you know how."*

**Go build something.**

::: notes
Say each line slowly, with weight.
Pause between lines.
This is the moment—let it land.
Then smile and move to Q&A.
:::

---

# Questions?

**Jakub Hubáček**

Flying Rat Studio

*Thank you!*

::: notes
15 minutes for Q&A.
If no questions immediately, have a backup: "One question I often get is..."
Possible backup questions:
- "How long did it take to build the Class Table Editor?"
- "What's the hardest part of building plugins?" → Testing, edge cases
- "Where do I start?" → Enable Bazinga, read the code, modify it
:::
