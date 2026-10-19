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

CONFIG="$HOME/.config/scratchpad/wezterm.lua"
VAULT="$HOME/Documents/vaults/primary"

PID=$(pgrep -f "wezterm-gui --config-file $CONFIG" | head -n1)

if [ -n "$PID" ]; then
    VISIBLE=$(osascript -e "tell application \"System Events\" to get visible of (first process whose unix id is $PID)" 2>/dev/null)
    if [ "$VISIBLE" = "true" ]; then
        osascript -e "tell application \"System Events\" to set visible of (first process whose unix id is $PID) to false" >/dev/null 2>&1
    else
        # frontmost=true both unhides and focuses (visible=true alone is flaky)
        osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $PID) to true" >/dev/null 2>&1
    fi
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
    -- nvim "$VAULT/TODAY.md"
