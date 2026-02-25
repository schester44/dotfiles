#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: watch-pane.sh --pane-id ID [options]

Watch a WezTerm pane and output new content as it appears.

Options:
  -p, --pane-id   WezTerm pane ID (required)
  -i, --interval  Poll interval in seconds (default: 0.5)
  -l, --lines     Number of history lines to track (default: 50)
  -h, --help      Show this help
USAGE
}

pane_id=""
interval=0.5
lines=50

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--pane-id)  pane_id="${2-}"; shift 2 ;;
    -i|--interval) interval="${2-}"; shift 2 ;;
    -l|--lines)    lines="${2-}"; shift 2 ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$pane_id" ]]; then
  echo "pane-id is required" >&2
  usage
  exit 1
fi

last_hash=""

while true; do
  content="$(wezterm cli get-text --pane-id "$pane_id" --start-line "-${lines}" 2>/dev/null)" || {
    echo "Pane $pane_id closed or not found" >&2
    exit 1
  }
  
  # Hash the content to detect changes
  current_hash="$(printf '%s' "$content" | md5 -q 2>/dev/null || printf '%s' "$content" | md5sum | cut -d' ' -f1)"
  
  if [[ "$current_hash" != "$last_hash" ]]; then
    # Clear and print separator for new content
    printf '\n--- PANE %s UPDATE ---\n' "$pane_id"
    printf '%s\n' "$content"
    last_hash="$current_hash"
  fi
  
  sleep "$interval"
done
