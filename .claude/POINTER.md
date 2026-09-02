# .claude/skills — Public Skills Index

Skills live in `.claude/skills/` in each repo and are synced to their public preview repos
via `gitexporter.config.json`. This file points to where you can find them.

---

Check out this Marp deck for more about skills: [Architecting Claude Code Skills for High-Impact](https://drasticstatic.github.io/trading-assistant-public-preview/setup/create-skill.marp.html)

---

## Skill Format

Each skill file uses a standard frontmatter header:

```markdown
---
name: skill-name
description: >
  One or two sentences. TRIGGER when: [conditions].
  Do NOT use for: [anti-triggers].
---

# Skill: /skill-name

[Instructions...]
```

The `description` field is what Claude Code reads to decide when to invoke the skill.
The body only loads when the skill is triggered — keeping context lean.

---

## Adding Skills to a New Repo

1. Create `.claude/skills/skill-name.md` following the format above
2. Update `gitexporter.config.json` — exclude `".claude/settings.local.json"` not `".claude/"`
3. Run `/create-skill`
4. Reference: [makemyskill.com](https://makemyskill.com)
