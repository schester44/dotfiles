#!/bin/bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DIR/accessories"
source "$DIR/finder"
source "$DIR/windows"
source "$DIR/dock"
source "$DIR/inputs"
source "$DIR/wallpaper"

# Apply keyboard shortcut changes without logging out
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
