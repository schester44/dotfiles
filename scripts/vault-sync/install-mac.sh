#!/bin/bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$HOME/.config/vault-sync/config"
[[ -f "$CONFIG" ]] || { echo "Create $CONFIG first (see README.md)" >&2; exit 1; }
[[ -x /opt/homebrew/bin/fswatch && -x /usr/bin/rsync ]] || {
  echo 'Install fswatch with brew; macOS rsync is also required' >&2
  exit 1
}
mkdir -p "$HOME/Library/LaunchAgents"
export VAULT_SYNC_DIR="$DIR"
/usr/bin/python3 - <<'PY'
import os
import plistlib
from pathlib import Path
home = Path.home()
directory = Path(os.environ['VAULT_SYNC_DIR'])
for label, command, extra in (
    ('local.vault-sync.watch', 'watch.sh', {'RunAtLoad': True, 'KeepAlive': True}),
    ('local.vault-sync.retry', 'sync.sh', {'StartInterval': 300}),
):
    plist = {'Label': label, 'ProgramArguments': [str(directory / command)] + (['--quiet'] if command == 'sync.sh' else []),
             'StandardOutPath': '/dev/null', 'StandardErrorPath': '/dev/null', **extra}
    with (home / 'Library/LaunchAgents' / (label + '.plist')).open('wb') as f:
        plistlib.dump(plist, f)
PY
for label in local.vault-sync.watch local.vault-sync.retry; do
  plist="$HOME/Library/LaunchAgents/$label.plist"
  launchctl bootout "gui/$UID" "$plist" 2>/dev/null || true
  launchctl bootstrap "gui/$UID" "$plist"
done
echo 'Installed vault-sync watcher and 5-minute retry job.'
