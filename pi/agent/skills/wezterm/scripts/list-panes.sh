#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: list-panes.sh [-q pattern] [--json]

List WezTerm panes with optional filtering.

Options:
  -q, --query   Case-insensitive substring to filter by title or command
  --json        Output raw JSON instead of formatted table
  -h, --help    Show this help
USAGE
}

query=""
json_output=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -q|--query) query="${2-}"; shift 2 ;;
    --json)     json_output=true; shift ;;
    -h|--help)  usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v wezterm >/dev/null 2>&1; then
  echo "wezterm not found in PATH" >&2
  exit 1
fi

# Get pane list as JSON
panes_json="$(wezterm cli list --format json 2>/dev/null)" || {
  echo "Failed to get pane list. Is WezTerm running?" >&2
  exit 1
}

if [[ -z "$panes_json" || "$panes_json" == "[]" ]]; then
  echo "No panes found"
  exit 0
fi

# Filter if query provided
if [[ -n "$query" ]]; then
  if command -v jq >/dev/null 2>&1; then
    query_lower="$(echo "$query" | tr '[:upper:]' '[:lower:]')"
    panes_json="$(echo "$panes_json" | jq --arg q "$query_lower" '[.[] | select((.title // "" | ascii_downcase | contains($q)) or (.cwd // "" | ascii_downcase | contains($q)))]')"
  else
    echo "Warning: jq not found, filtering disabled" >&2
  fi
fi

if [[ "$json_output" == true ]]; then
  echo "$panes_json"
  exit 0
fi

# Format as table
if command -v jq >/dev/null 2>&1; then
  echo "PANE_ID  WORKSPACE    TAB  TITLE"
  echo "-------  -----------  ---  -----"
  echo "$panes_json" | jq -r '.[] | "\(.pane_id)\t\(.workspace // "default")\t\(.tab_id)\t\(.title // "—")"' | \
    while IFS=$'\t' read -r pane_id workspace tab_id title; do
      printf "%-7s  %-11s  %-3s  %s\n" "$pane_id" "$workspace" "$tab_id" "$title"
    done
else
  # Fallback without jq
  wezterm cli list
fi
