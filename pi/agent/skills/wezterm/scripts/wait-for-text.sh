#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: wait-for-text.sh --pane-id ID --pattern PATTERN [options]

Poll a WezTerm pane for text and exit when found.

Options:
  -p, --pane-id   WezTerm pane ID (required)
  -P, --pattern   Regex pattern to look for (required)
  -F, --fixed     Treat pattern as a fixed string (grep -F)
  -T, --timeout   Seconds to wait (integer, default: 15)
  -i, --interval  Poll interval in seconds (default: 0.5)
  -l, --lines     Number of history lines to inspect (integer, default: 1000)
  -h, --help      Show this help
USAGE
}

pane_id=""
pattern=""
grep_flag="-E"
timeout=15
interval=0.5
lines=1000

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--pane-id)  pane_id="${2-}"; shift 2 ;;
    -P|--pattern)  pattern="${2-}"; shift 2 ;;
    -F|--fixed)    grep_flag="-F"; shift ;;
    -T|--timeout)  timeout="${2-}"; shift 2 ;;
    -i|--interval) interval="${2-}"; shift 2 ;;
    -l|--lines)    lines="${2-}"; shift 2 ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$pane_id" || -z "$pattern" ]]; then
  echo "pane-id and pattern are required" >&2
  usage
  exit 1
fi

if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
  echo "timeout must be an integer number of seconds" >&2
  exit 1
fi

if ! [[ "$lines" =~ ^[0-9]+$ ]]; then
  echo "lines must be an integer" >&2
  exit 1
fi

if ! command -v wezterm >/dev/null 2>&1; then
  echo "wezterm not found in PATH" >&2
  exit 1
fi

# End time in epoch seconds
start_epoch=$(date +%s)
deadline=$((start_epoch + timeout))

while true; do
  # Get text from pane, using negative start-line for scrollback
  pane_text="$(wezterm cli get-text --pane-id "$pane_id" --start-line "-${lines}" 2>/dev/null || true)"

  if printf '%s\n' "$pane_text" | grep $grep_flag -- "$pattern" >/dev/null 2>&1; then
    exit 0
  fi

  now=$(date +%s)
  if (( now >= deadline )); then
    echo "Timed out after ${timeout}s waiting for pattern: $pattern" >&2
    echo "Last ${lines} lines from pane $pane_id:" >&2
    printf '%s\n' "$pane_text" >&2
    exit 1
  fi

  sleep "$interval"
done
