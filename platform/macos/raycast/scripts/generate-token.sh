#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate Secure Token
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔐
# @raycast.packageName Generate Secure Token
# @raycast.argument1 { "type": "text", "placeholder": "bytes (default 32)", "optional": true }

# Documentation:
# @raycast.description Generates a secure random hex string (openssl rand -hex) and copies it to the clipboard
# @raycast.author Stee
# @raycast.authorURL https://github.com/schester44

BYTES="${1:-32}"

TOKEN=$(openssl rand -hex "$BYTES")

echo -n "$TOKEN" | pbcopy
echo "Token copied ($((${#TOKEN})) chars)"
