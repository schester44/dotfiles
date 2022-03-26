#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate Email
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Generate Email

# Documentation:
# @raycast.description Generates an email address for testing
# @raycast.author Stee
# @raycast.authorURL https://github.com/schester44

EMAIL_PREFIX="steve+dev"
EMAIL_DOMAIN="@obierisk.com"

DATE=$(date +'%m%d%y-%H%M%S')

echo "Email copied"
echo "$EMAIL_PREFIX+$DATE$EMAIL_DOMAIN" | pbcopy
