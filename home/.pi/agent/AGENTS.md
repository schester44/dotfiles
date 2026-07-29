# System Context

## Operating System
Detect the OS at runtime using `uname -s` before making OS-specific decisions.

- **macOS (Darwin)**: Use `brew` as the package manager. Prefer Homebrew formulae and macOS conventions.
- **Linux (Arch)**: Use `pacman` (or `yay`/`paru` for AUR) as the package manager. Prefer Arch conventions and packages.

## User
- Home directory: `~`
- Default working directory: `~/Documents`

## Obsidian
- Vault path: `~/Documents/vaults/primary`
- Use spaces in filenames (Obsidian convention), not hyphens
- Key folders: `Work/Obie/`, `Projects/`, `daily/`, `Ideas.md`
- Attachments go in `_attachments/`
