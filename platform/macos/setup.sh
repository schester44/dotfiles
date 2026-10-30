#!/bin/bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DIR/accessories"
source "$DIR/finder"
source "$DIR/dock"
source "$DIR/inputs"
source "$DIR/wallpaper"
