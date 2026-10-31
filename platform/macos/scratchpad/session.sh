#!/bin/bash
# Runs inside the scratchpad WezTerm window (launched by toggle.sh).
#
# Keeps nvim alive across quits: when nvim exits (:q, :wq, ZZ, ...) the window
# is hidden and nvim is restarted in the background, reopening the last file.
# The next toggle shows it instantly instead of cold-starting WezTerm + nvim.
#
# `:cq` (non-zero exit) quits the scratchpad for real.

VAULT="$HOME/Documents/vaults/primary"
DEFAULT_DOCUMENT="$VAULT/Index.md"
# Written by nvim (see lazy-plugins/obsidian.lua) when SCRATCHPAD=1
STATE_FILE="$HOME/.local/state/scratchpad/last-file"

last_document() {
    if [ -f "$STATE_FILE" ]; then
        local last
        last=$(head -n1 "$STATE_FILE")
        if [ -n "$last" ] && [ -f "$last" ]; then
            echo "$last"
            return
        fi
    fi
    echo "$DEFAULT_DOCUMENT"
}

# Ask WezTerm to hide the app: sets a user var, handled by the
# `user-var-changed` event in wezterm.lua. The value changes on every call so
# the event fires even if WezTerm ignores repeated identical values.
hide_window() {
    local value
    value=$(printf 'hide-%s' "$1" | base64)
    printf '\033]1337;SetUserVar=%s=%s\007' scratchpad "$value"
}

export SCRATCHPAD=1
count=0
while true; do
    nvim "$(last_document)" || exit 0
    count=$((count + 1))
    hide_window "$count"
done
