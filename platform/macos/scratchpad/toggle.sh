#!/bin/bash
# Toggle a floating WezTerm scratchpad with nvim + TODAY.md
#   - Not running        → launch on current workspace
#   - On current workspace → kill it
#   - On other workspace  → pull it here and focus

CONFIG="$HOME/.config/scratchpad/wezterm.lua"
VAULT="$HOME/Documents/vaults/primary"
PID_FILE="/tmp/scratchpad.pid"
CURRENT_WS=$(aerospace list-workspaces --focused)

find_window() {
    aerospace list-windows "$@" --json 2>/dev/null \
        | python3 -c "
import json, sys
for w in json.load(sys.stdin):
    if w.get('window-title') == 'scratchpad':
        print(w['window-id'])
        break
" 2>/dev/null
}

# Check if scratchpad exists at all
WINDOW_ID=$(find_window --all)

if [ -n "$WINDOW_ID" ]; then
    # Check if it's on the focused workspace
    LOCAL_ID=$(find_window --workspace focused)

    if [ -n "$LOCAL_ID" ]; then
        # On this workspace — kill it
        if [ -f "$PID_FILE" ]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null
            rm -f "$PID_FILE"
        fi
    else
        # On another workspace — pull it here and focus
        aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$CURRENT_WS" 2>/dev/null
        aerospace layout --window-id "$WINDOW_ID" floating 2>/dev/null
        aerospace focus --window-id "$WINDOW_ID" 2>/dev/null
    fi
    exit 0
fi

# Not running — launch a new instance
/Applications/WezTerm.app/Contents/MacOS/wezterm \
    --config-file "$CONFIG" \
    start --always-new-process \
    --class scratchpad \
    --cwd "$VAULT" \
    -- nvim TODAY.md &

# Wait for the wezterm-gui process, then track and float it
(
    for i in $(seq 1 30); do
        GUI_PID=$(pgrep -f "scratchpad/wezterm.lua" | head -1)
        if [ -n "$GUI_PID" ]; then
            echo "$GUI_PID" > "$PID_FILE"
            break
        fi
        sleep 0.15
    done

    for i in $(seq 1 30); do
        WINDOW_ID=$(find_window --all)
        if [ -n "$WINDOW_ID" ]; then
            aerospace move-node-to-workspace --window-id "$WINDOW_ID" "$CURRENT_WS" 2>/dev/null
            aerospace layout --window-id "$WINDOW_ID" floating 2>/dev/null
            aerospace focus --window-id "$WINDOW_ID" 2>/dev/null
            break
        fi
        sleep 0.15
    done

    # Clean up PID file when process exits
    if [ -n "$GUI_PID" ]; then
        while kill -0 "$GUI_PID" 2>/dev/null; do sleep 1; done
        rm -f "$PID_FILE"
    fi
) &
disown
