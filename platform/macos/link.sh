#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DEST="$HOME/.config"

mkdir -p "$CONFIG_DEST"

# Aerospace
ln -sf "$DIR/aerospace" "$CONFIG_DEST/aerospace"

# Rift
ln -sf "$DIR/rift" "$CONFIG_DEST/rift"

# Sketchybar
ln -sf "$DIR/sketchybar" "$CONFIG_DEST/sketchybar"

# Karabiner
ln -sf "$DIR/karabiner" "$CONFIG_DEST/karabiner"
