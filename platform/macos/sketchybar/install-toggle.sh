#!/usr/bin/env bash
# Build our fork without modifying Homebrew's installation or a working checkout.
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  echo "sketchybar-toggle requires macOS" >&2
  exit 1
fi

SOURCE_URL=https://github.com/schester44/sketchybar-toggle.git
# Pin the tested fork revision. Update this when adopting further fork changes.
REVISION=4ea5023
BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/sketchybar-toggle.XXXXXX")
trap 'rm -rf "$BUILD_DIR"' EXIT

git clone --quiet "$SOURCE_URL" "$BUILD_DIR/source"
git -C "$BUILD_DIR/source" checkout --quiet "$REVISION"
(
  cd "$BUILD_DIR/source"
  swift test
  swift build -c release
)

mkdir -p "$HOME/.local/bin"
# Stage then rename so a running process is not overwritten in place.
STAGED=$(mktemp "$HOME/.local/bin/.sketchybar-toggle.XXXXXX")
trap 'rm -rf "$BUILD_DIR"; rm -f "$STAGED"' EXIT
install -m 755 "$BUILD_DIR/source/.build/release/sketchybar-toggle" "$STAGED"
mv -f "$STAGED" "$HOME/.local/bin/sketchybar-toggle"
printf 'Installed fork revision %s at %s\n' "$REVISION" "$HOME/.local/bin/sketchybar-toggle"
echo 'Reload SketchyBar to restart the daemon with the new binary.'
