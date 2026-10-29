#!/bin/bash
# One-way mirror. Run via the watcher or the periodic launchd job.
set -u

QUIET=false
for arg in "$@"; do
  [[ "$arg" == --quiet ]] && QUIET=true
done

CONFIG="${VAULT_SYNC_CONFIG:-$HOME/.config/vault-sync/config}"
if [[ ! -f "$CONFIG" ]]; then
  [[ "$QUIET" == true ]] || printf 'vault-sync: not configured (%s)\n' "$CONFIG" >&2
  exit 1
fi
# Local, user-owned configuration; do not put passwords in this file.
# shellcheck source=/dev/null
source "$CONFIG"

SOURCE_DIR="${SOURCE_DIR:-$HOME/Documents/vaults}"
LOG_FILE="${LOG_FILE:-$HOME/Library/Logs/vault-sync.log}"
SSH_ALIAS="${SSH_ALIAS:-}"
REMOTE_PATH="${REMOTE_PATH:-}"

# Restrict remote arguments to simple paths so neither ssh nor rsync can
# interpret shell syntax. Always use a dedicated destination for --delete.
if [[ ! "$SSH_ALIAS" =~ ^[a-zA-Z0-9_.-]+$ || ! "$REMOTE_PATH" =~ ^/[a-zA-Z0-9_./-]+$ || "$REMOTE_PATH" == / || "$REMOTE_PATH" == *..* || ! -d "$SOURCE_DIR" ]]; then
  printf 'vault-sync: invalid config or missing source directory\n' >&2
  exit 1
fi

if [[ "${1:-}" != --locked ]]; then
  mkdir -p "$HOME/.local/state/vault-sync"
  # Prevent the watcher and the periodic retry from running rsync together.
  /usr/bin/lockf -s -t 0 "$HOME/.local/state/vault-sync/sync.lock" "$0" --locked "$@"
  exit $?
fi

RSYNC="${RSYNC_BIN:-/usr/bin/rsync}"
[[ -x "$RSYNC" ]] || { printf 'vault-sync: rsync not found\n' >&2; exit 1; }
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
chmod 600 "$LOG_FILE"

# No prompts and no log noise when disconnected, locked out, or offline.
SSH_OPTIONS=(-o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1)
if ! /usr/bin/ssh "${SSH_OPTIONS[@]}" "$SSH_ALIAS" true </dev/null >/dev/null 2>&1; then
  [[ "$QUIET" == true ]] || printf 'vault-sync: server unavailable; skipped\n'
  exit 0
fi
# A reachable host with a missing directory is a configuration error, not an
# offline event. Refuse to let rsync create the destination implicitly.
# shellcheck disable=SC2029 # Remote path is intentionally expanded locally; validated above.
if ! /usr/bin/ssh "${SSH_OPTIONS[@]}" "$SSH_ALIAS" "test -d '$REMOTE_PATH'" </dev/null >/dev/null 2>&1; then
  message="vault-sync: destination directory missing or inaccessible: $REMOTE_PATH"
  printf '%s ERROR %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$message" >>"$LOG_FILE"
  [[ "$QUIET" == true ]] || printf '%s\n' "$message" >&2
  exit 1
fi

output=$(mktemp)
trap 'rm -f "$output"' EXIT
[[ "$QUIET" == true ]] || printf 'Syncing %s -> %s:%s ...\n' "$SOURCE_DIR" "$SSH_ALIAS" "$REMOTE_PATH"
if "$RSYNC" -azi --delete --timeout=30 \
    --exclude='.obsidian/' --filter='-s .DS_Store' \
    -e "/usr/bin/ssh -o BatchMode=yes -o ConnectTimeout=5 -o ConnectionAttempts=1" \
    "$SOURCE_DIR/" "$SSH_ALIAS:$REMOTE_PATH/" >"$output" 2>&1; then
  printf '%s SUCCESS %s -> %s:%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$SOURCE_DIR" "$SSH_ALIAS" "$REMOTE_PATH" >>"$LOG_FILE"
  if [[ "$QUIET" != true ]]; then
    if [[ -s "$output" ]]; then
      printf 'Changes:\n'
      /bin/cat "$output"
    else
      printf 'No changes.\n'
    fi
    printf 'Sync complete.\n'
  fi
else
  status=$?
  {
    printf '%s ERROR rsync exit %s: ' "$(date '+%Y-%m-%d %H:%M:%S')" "$status"
    tr '\n' ' ' <"$output" | cut -c 1-500
    printf '\n'
  } >>"$LOG_FILE"
  if [[ "$QUIET" != true ]]; then
    printf 'Sync failed (rsync exit %s):\n' "$status" >&2
    /bin/cat "$output" >&2
  fi
  exit "$status"
fi
