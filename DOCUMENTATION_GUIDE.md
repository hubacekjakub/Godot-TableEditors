# 📚 Project Documentation Guide

This guide explains the current active documentation structure for the Godot Sheet Editor project.

## Active Documentation Files

### 1. **README.md** - Start Here! 📖
**What it contains:**
- Quick project overview
- Installation and setup
- Feature summary with status table
- How to run tests
- Development workflow
- Links to detailed docs

**Who should read it:**
- New developers
- Project overview seekers
- Anyone getting started

**Keep it:** Short, clear, actionable

---

### 2. **PLAN.md** - Project Roadmap 🗺️
**What it contains:**
- All 128 project tasks organized by phase and plugin
- Current status with completion percentage
- Phase breakdown (Phase 0-4)
- Task IDs and descriptions
- Timeline estimates

**Who should read it:**
- Project managers
- Task planning and tracking
- Feature prioritization

**Update frequency:** Weekly or per phase completion

---

### 3. **DEVELOPMENT.md** - Developer Guide 🛠️
**What it contains:**
- Local setup instructions
- Code standards and conventions
- GDScript style guide
- Testing procedures (how to run, write tests)
- Architecture explanation
- Contributing workflow
- Debugging tips and common issues
- Learning resources

**Who should read it:**
- Active developers
- Code reviewers
- Contributors
- New team members

**Keep it:** Practical and actionable

---

### 4. **AGENTS.md** - Session Log 📝
**What it contains:**
- AI development session documentation
- What was built (implementation details)
- Issues encountered and solutions (48 issues → 0 errors)
- Development decisions and rationale
- Key implementation patterns
- Test strategy and coverage metrics
- Performance analysis
- Lessons learned and recommendations
- Session statistics and quality metrics

**Who should read it:**
- Technical leads
- Code reviewers
- Developers wanting deep context
- Future AI development sessions

**Update frequency:** Per major development session

---

## Documentation Organization

```
Godot-SheetEditor/
│
├── README.md                    # Quick start (you are here!)
├── PLAN.md                      # Task roadmap
├── DEVELOPMENT.md               # Developer guide
├── AGENTS.md                    # Development session log
│
├── docs/
│   ├── implementation/
│   │   └── P2_SUMMARY.md       # P2-001-008 deep dive
│   ├── testing/
│   │   └── TEST_GUIDE.md       # Testing procedures
│   └── reference/              # (for future API docs)
│
└── .archive/                    # Historical documentation
    └── README.md               # Archive guide
```

## Quick Start by Use Case

### "I'm new to the project"
1. Read **README.md** (5 min)
2. Read **DEVELOPMENT.md** setup section (10 min)
3. Run tests following **docs/testing/TEST_GUIDE.md** (15 min)
4. Start coding!

### "I need to understand what was done"
1. Check **PLAN.md** for the feature ID
2. Read **AGENTS.md** for implementation context
3. Read **docs/implementation/P2_SUMMARY.md** for details
4. Review code in `addons/class_table_editor/`

### "I want to write tests"
1. Read **docs/testing/TEST_GUIDE.md**
2. Check existing tests in `scripts/Test*.gd`
3. Follow the patterns shown
4. Run with `scenes/TestRunner.tscn`

### "I need to know what's left to do"
1. Open **PLAN.md**
2. Look for ⭕ or ❌ marks (not completed)
3. Check phase descriptions and timelines

### "I'm hunting a bug"
1. Check **DEVELOPMENT.md** debugging section
2. Search **AGENTS.md** for similar issues
3. Look in `.archive/` for fix documentation
4. Check git history for related commits

## File Maintenance

### Keep Clean ✨
- **README.md**: Update when features change (keep <300 lines)
- **PLAN.md**: Update when tasks completed (source of truth)
- **DEVELOPMENT.md**: Update when workflows change (keep practical)
- **AGENTS.md**: Keep as-is (historical record per session)

### Archive Policy 📦
- Session-specific docs → `.archive/`
- Historical updates → `.archive/`
- Phase completion reports → `.archive/`
- Fix tracking → `.archive/`

### Never Delete
- PLAN.md (roadmap)
- DEVELOPMENT.md (workflow)
- README.md (entry point)
- Git history (always available)

## What NOT To Do

❌ Don't create task-specific docs (use PLAN.md instead)
❌ Don't create bug fix docs (document in AGENTS.md next session)
❌ Don't create "status update" markdown files
❌ Don't keep multiple versions of the same doc

## Navigation Tips

### Finding Information
- **"What's the roadmap?"** → PLAN.md
- **"How do I set up?"** → DEVELOPMENT.md (Setup section)
- **"How do I write tests?"** → docs/testing/TEST_GUIDE.md
- **"Why was X implemented that way?"** → AGENTS.md
- **"What features exist?"** → README.md
- **"Old info about X?"** → .archive/ folder

### Updating Information
1. **Feature status changes?** → Update PLAN.md
2. **Setup changes?** → Update DEVELOPMENT.md
3. **New session?** → Create new AGENTS.md or append
4. **New phase?** → Create docs/implementation/P[n]_SUMMARY.md
5. **Outdated doc?** → Archive it, don't leave stale docs

## Current Status

✅ **4 active documentation files** (clean, focused)
✅ **26 archived files** (preserved in .archive/)
📁 **docs/ folder** with organized deep-dives
🗺️ **Clear navigation** between all docs

---

## Questions?

- **How to contribute?** → See DEVELOPMENT.md
- **What features work?** → See README.md or PLAN.md
- **How is code organized?** → See AGENTS.md or DEVELOPMENT.md
- **Where's old docs?** → See .archive/README.md

---

**Last Updated:** October 18, 2025
**Status:** Active, maintained
