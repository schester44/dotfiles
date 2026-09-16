---
name: memory
description: Search and record long-term memories (debugging findings, system quirks, decisions, how-tos). Use when the user reports a problem that might have occurred before, asks "have we seen this?", says "remember this" / "save this", or when a debugging session uncovers a non-obvious root cause worth recording.
---

# Memory System

Memories live in `~/.pi/agent/memories/` — one markdown file per memory.

## Searching (do this FIRST when debugging anything that smells recurring)

```bash
# Search everything (frontmatter keywords + body)
rg -il "<term>" ~/.pi/agent/memories/

# Multiple candidate terms
rg -il "aerospace|hotkey|shortcut" ~/.pi/agent/memories/

# Browse the index
cat ~/.pi/agent/memories/INDEX.md
```

Search with **symptom words** (what the user is saying) first, then topic words.
Read any matching memory in full before re-debugging from scratch.

## Recording a new memory

1. Create `~/.pi/agent/memories/YYYY-MM-DD-short-slug.md` using the template below.
2. Append a one-line entry to `~/.pi/agent/memories/INDEX.md`.

### Template

```markdown
---
date: YYYY-MM-DD
tags: [topic1, topic2]
keywords: symptom-phrased terms the user would actually say when this recurs,
  plus cause terms, app names, error messages
---

# Title (symptom-oriented)

## Symptom
What it looks like when it happens.

## Root cause
The actual cause, and why it's non-obvious.

## Diagnosis
Exact commands/steps to identify it, with expected output.

## Fix
Exact steps/commands to resolve.

## Prevention / notes
Recurrence triggers, related apps, gotchas.
```

### Writing rules for findability

- **Keywords are the search surface.** Include the user's literal phrasing of the
  symptom ("option numbers not working"), app names, error text, and cause terms.
- Title by symptom, not cause — the symptom is known at search time; the cause isn't.
- Keep diagnosis commands copy-pasteable with expected output shown.
- One memory per distinct lesson. Update an existing memory rather than duplicating;
  add new keywords when a new phrasing of the same issue shows up.

## Maintenance

- If a memory turns out to be wrong or incomplete, edit it — don't create a corrective duplicate.
- INDEX.md format: `- YYYY-MM-DD [slug](./file.md) — one-line symptom summary`
