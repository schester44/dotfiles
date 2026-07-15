#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clip to Scratchpad
# @raycast.mode silent
# @raycast.packageName Utilities

# Optional parameters:
# @raycast.icon 📎

# Documentation:
# @raycast.description Save clipboard contents as a bullet in TODAY.md

FILE="$HOME/Documents/vaults/primary/TODAY.md"

CLIP=$(pbpaste)

if [[ -z "$CLIP" ]]; then
    echo "Clipboard is empty"
    exit 1
fi

# Indent multiline content under the bullet
FORMATTED=$(echo "$CLIP" | awk 'NR==1 {print "- " $0} NR>1 {print "  " $0}')

echo "" >> "$FILE"
echo "$FORMATTED" >> "$FILE"

echo "Clipped to scratchpad ✓"
