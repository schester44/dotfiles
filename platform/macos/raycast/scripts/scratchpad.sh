#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Scratchpad
# @raycast.mode silent
# @raycast.packageName Utilities

# Optional parameters:
# @raycast.icon 📝

# Documentation:
# @raycast.description Toggle a floating nvim scratchpad (TODAY.md)

bash "$HOME/.config/scratchpad/toggle.sh" >/dev/null 2>&1
