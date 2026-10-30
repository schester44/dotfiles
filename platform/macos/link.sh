#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DEST="$HOME/.config"

mkdir -p "$CONFIG_DEST"

# Rift
ln -sfn "$DIR/rift" "$CONFIG_DEST/rift"

# Sketchybar
ln -sfn "$DIR/sketchybar" "$CONFIG_DEST/sketchybar"

# Karabiner
ln -sfn "$DIR/karabiner" "$CONFIG_DEST/karabiner"
