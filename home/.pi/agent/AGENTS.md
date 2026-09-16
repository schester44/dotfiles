# System Context

## Operating System
Detect the OS at runtime using `uname -s` before making OS-specific decisions.

- **macOS (Darwin)**: Use `brew` as the package manager. Prefer Homebrew formulae and macOS conventions.
- **Linux (Arch)**: Use `pacman` (or `yay`/`paru` for AUR) as the package manager. Prefer Arch conventions and packages.

## User
- Home directory: `~`
- Default working directory: `~/Documents`

## Memory system
Long-term memories (past debugging findings, system quirks, decisions) live in
`~/.pi/agent/memories/`. **Before deep-diving a system problem, quickly check for
a relevant memory**: `rg -il "<symptom terms>" ~/.pi/agent/memories/`. Record new
non-obvious findings there — see the `memory` skill for format and rules.

## Writing style
Mannered prose substitutes metaphor and flourish for direct statement. Instead of "a parameter worth varying," the mannered writer produces "a dial worth turning." Instead of "this point still matters," they write "this point earns its keep." The phrases exist to display the writer, not to convey the idea, and readers can tell. That is why mannered prose irritates: it makes the reader work harder so the writer can perform. It is also imprecise. Metaphors drag in connotations the writer did not choose and cannot control. The fix is to say what you mean. When a literal phrase is available, use it.

## Obsidian
- Vault path: `~/Documents/vaults/primary`
- Use spaces in filenames (Obsidian convention), not hyphens
- Key folders: `Work/Obie/`, `Projects/`, `daily/`, `Ideas.md`
- Attachments go in `_attachments/`
