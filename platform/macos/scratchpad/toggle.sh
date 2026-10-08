#!/bin/bash
# Toggle a floating WezTerm scratchpad with nvim + TODAY.md
#   - Not running          → launch on current workspace
#   - On current workspace → stash it (hide)
#   - Stashed/other ws     → pull it here and focus

# Raycast runs scripts with a bare PATH; aerospace/jq live in homebrew
export PATH="/opt/homebrew/bin:$PATH"

CONFIG="$HOME/.config/scratchpad/wezterm.lua"
VAULT="$HOME/Documents/vaults/primary"
STASH_WS="scratch-stash"
CURRENT_WS=$(aerospace list-workspaces --focused)

find_window() {
    aerospace list-windows "$@" --json 2>/dev/null \
        | jq -r '[.[] | select(.["window-title"] == "scratchpad")][0] // empty | .["window-id"]' 2>/dev/null
}

# Check if scratchpad exists at all
WINDOW_ID=$(find_window --all)

if [ -n "$WINDOW_ID" ]; then
    LOCAL_ID=$(find_window --workspace focused)

    if [ -n "$LOCAL_ID" ]; then
        # On this workspace — stash it
        aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$STASH_WS" 2>/dev/null
    else
        # Stashed or on another workspace — pull it here
        aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$CURRENT_WS" 2>/dev/null
        aerospace layout --window-id "$WINDOW_ID" floating 2>/dev/null
        aerospace focus --window-id "$WINDOW_ID" 2>/dev/null
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

# Wait for window to appear, then float it on current workspace
(
    for i in $(seq 1 30); do
        WINDOW_ID=$(find_window --all)
        if [ -n "$WINDOW_ID" ]; then
            aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$CURRENT_WS" 2>/dev/null
            aerospace layout --window-id "$WINDOW_ID" floating 2>/dev/null
            aerospace focus --window-id "$WINDOW_ID" 2>/dev/null
            break
        fi
        sleep 0.1
    done
) &
disown
