# Scratchpad

A floating, always-on-top WezTerm scratchpad that opens `TODAY.md` in Neovim — perfect for quick notes, todo lists, and daily journaling without leaving your current workflow.

## How It Works

The scratchpad is a dedicated WezTerm instance with its own config that behaves like a drop-down/quake-style terminal. It toggles through three states:

| State | Action |
|---|---|
| **Not running** | Launches a new WezTerm window, opens `~/Documents/vaults/primary/TODAY.md` in nvim |
| **Visible on current workspace** | Stashes the window to a hidden workspace (`scratch-stash`) |
| **Stashed / on another workspace** | Pulls the window back to the current workspace and focuses it |

## Trigger

Bound to **⌥N** (Option + N) via [Raycast](https://www.raycast.com/) as a script command. One keystroke to summon, one to dismiss.

## Files

- **`toggle.sh`** — The toggle script. Uses [AeroSpace](https://github.com/nikitabobko/AeroSpace) to manage window placement across workspaces.
- **`wezterm.lua`** — Dedicated WezTerm config for the scratchpad window.

## Stash, Don't Kill

Dismissing the scratchpad doesn't close the process — it moves the window to a hidden `scratch-stash` workspace managed by AeroSpace. The next toggle just pulls it back instantly, skipping the WezTerm + nvim startup entirely. The window is only launched fresh on the very first invocation (or if the process was manually closed).

## Window Behavior

- **Always on top** — stays visible over other windows
- **Floating layout** — not affected by AeroSpace tiling
- **Positioned top-right** — anchored to the right edge of the screen with padding
- **Semi-transparent** with macOS background blur
- **No tab bar** or close confirmation — single-purpose, fast to dismiss
- **80×40** columns/rows default size
- Reuses the main WezTerm theme (via shared `theme.lua`)

## Dependencies

- [WezTerm](https://wezfurlong.org/wezterm/)
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) (tiling window manager)
- [Raycast](https://www.raycast.com/) (hotkey trigger)
- Neovim
- A shared WezTerm `theme.lua` at `~/.config/wezterm/theme.lua`
