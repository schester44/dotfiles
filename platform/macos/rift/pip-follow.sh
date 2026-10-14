#!/bin/sh
# Google Meet PIP follow: when switching workspaces, bring the Chrome PIP
# window (title "about:blank") along to the new workspace.
# Port of the old aerospace on-workspace-change.sh PIP logic.
# Invoked by: rift-cli subscribe cli --event workspace_changed

ws_name="$RIFT_WORKSPACE_NAME"
[ -n "$ws_name" ] || exit 0

RIFT=/opt/homebrew/bin/rift-cli
JQ=/opt/homebrew/bin/jq

"$RIFT" query workspaces | "$JQ" -r --arg ws "$ws_name" '
  ([.[] | select(.name == $ws)][0].index) as $target
  | .[]
  | select(.name != $ws)
  | .windows[]
  | select(.app_name == "Google Chrome" and (.title | startswith("about:blank")))
  | "\(.window_server_id) \($target)"
' | while read -r wid target; do
  [ -n "$wid" ] && [ -n "$target" ] && "$RIFT" execute workspace move-window "$target" "$wid"
done
exit 0
