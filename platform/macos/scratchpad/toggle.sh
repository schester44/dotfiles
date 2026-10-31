#!/bin/bash
# Toggle a floating WezTerm scratchpad with nvim + TODAY.md
#   - Not running → launch
#   - Visible     → hide (app-level hide; keeps the nvim session alive)
#   - Hidden      → unhide + focus
#
# The scratchpad window is AlwaysOnTop (window-server layer 3), which rift
# does not track — so instead of moving it between virtual workspaces we
# toggle visibility at the app level via System Events. Since the window is
# always-on-top it follows across workspaces while shown, quake-style.

# Raycast runs scripts with a bare PATH
export PATH="/opt/homebrew/bin:$PATH"

# nvim is launched directly (not via zsh), so .zshrc's nvm PATH setup never
# runs. Add the newest nvm node so node-based LSPs (copilot, oxfmt) can start.
NODE_BIN=$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | sort -V | tail -n1)
[ -n "$NODE_BIN" ] && PATH="$NODE_BIN:$PATH"
NVIM_PATH="$HOME/.local/bin:$PATH"

CONFIG="$HOME/.dotfiles/platform/macos/scratchpad/wezterm.lua"
SESSION="$HOME/.dotfiles/platform/macos/scratchpad/session.sh"
VAULT="$HOME/Documents/vaults/primary"

PID=$(pgrep -f "wezterm-gui --config-file $CONFIG" | head -n1)

# Hide/unhide via NSRunningApplication in a single JXA call. This is ~4x
# faster than going through System Events (one osascript call instead of two,
# and no Apple Event round trip to the System Events process).
TOGGLE_JS='
function run(argv) {
    ObjC.import("AppKit")
    const app = $.NSRunningApplication.runningApplicationWithProcessIdentifier(Number(argv[0]))
    if (app.isHidden) {
        app.unhide
        app.activateWithOptions($.NSApplicationActivateIgnoringOtherApps)
    } else {
        app.hide
    }
}'

if [ -n "$PID" ]; then
    osascript -l JavaScript -e "$TOGGLE_JS" "$PID" >/dev/null 2>&1
    exit 0
fi

# Not running — launch a new instance.
# Use `open` so launchd (not the caller, e.g. Raycast) is the responsible
# process for TCC — otherwise nvim gets Permission Denied on ~/Documents.
open -na WezTerm --args \
    --config-file "$CONFIG" \
    start --always-new-process \
    --class scratchpad \
    --cwd "$VAULT" \
    -- env PATH="$NVIM_PATH" bash "$SESSION"
