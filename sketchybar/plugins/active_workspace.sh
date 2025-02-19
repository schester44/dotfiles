#!/bin/bash

# TODO, Why do all of the Letter workspaces inherit the last value?

declare -A spaceNames=(
  [1]="Browser"
  [2]="ChatGPT"
  [3]="Database"
  [4]="Utils"
  [5]="Unused"
  ["P"]="Personal"
  ["S"]="Slack"
  ["W"]="WezTerm"
)

sketchybar --set "$NAME" label="${spaceNames[$FOCUSED_WORKSPACE]}"
