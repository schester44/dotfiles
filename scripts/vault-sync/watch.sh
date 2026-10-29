#!/bin/bash
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$HOME/Documents/vaults"
CONFIG="$HOME/.config/vault-sync/config"
if [[ -f "$CONFIG" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG"
fi
SOURCE_DIR="${SOURCE_DIR:-$HOME/Documents/vaults}"
"$DIR/sync.sh" --quiet
# fswatch batches changes for 10 seconds; sync.sh serializes overlapping runs.
/opt/homebrew/bin/fswatch -o -l 10 "$SOURCE_DIR" | while IFS= read -r _; do
  "$DIR/sync.sh" --quiet
done
