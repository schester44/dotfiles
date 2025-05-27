#!/bin/bash

LOG_FILE="$HOME/.aerospace_workspace_change.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOG_FILE"
}

# Notify sketchybar
if ! sketchybar --trigger aerospace_workspace_changed \
  PREV_WORKSPACE="$AEROSPACE_PREV_WORKSPACE" \
  FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"; then
  log "Error: sketchybar trigger failed."
fi
#
ws=${1:-$AEROSPACE_FOCUSED_WORKSPACE}
IFS=$'\n' all_wins=$(aerospace list-windows --all --format '%{window-id}|%{app-name}|%{window-title}|%{monitor-id}|%{workspace}')
IFS=$'\n' all_ws=$(aerospace list-workspaces --all --format '%{workspace}|%{monitor-id}')

# about:blank is the Google Meet PIP window title
pip_titles=("about:blank")

# Function to find matching PIP windows
find_pip_windows() {
  local titles=("$@")
  local result=""

  for title in "${titles[@]}"; do
    local matches=$(printf '%s\n' "$all_wins" | rg "$title")
    result="$result"$'\n'"$matches"
  done
  echo "$result" | sed '/^\s*$/d' # Remove empty lines
}

pip_wins=$(find_pip_windows "${pip_titles[@]}")

target_mon=$(printf '%s\n' "$all_ws" | rg "^$ws" | cut -d'|' -f2 | xargs)

move_win() {
  local win="$1"

  [[ -n $win ]] || return 0

  local win_mon=$(echo "$win" | cut -d'|' -f4 | xargs)
  local win_id=$(echo "$win" | cut -d'|' -f1 | xargs)
  local win_app=$(echo "$win" | cut -d'|' -f2 | xargs)
  local win_ws=$(echo "$win" | cut -d'|' -f5 | xargs)

  # Skip if the monitor is already the target monitor or if the workspace matches
  [[ $target_mon != "$win_mon" ]] && return 0
  [[ $ws == "$win_ws" ]] && return 0

  log "Moving window: $win_app ($win_id) from workspace $win_ws to $ws"
  aerospace move-node-to-workspace --window-id "$win_id" "$ws"
}

# Process each PIP window found
echo "$pip_wins" | while IFS= read -r win; do
  move_win "$win"
done
