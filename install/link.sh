#!/usr/bin/env bash

set -euo pipefail

HOME_SOURCE="$DOTFILES/home"
CONFIG_SOURCE="$HOME_SOURCE/.config"
CONFIG_DEST="$HOME/.config"

mkdir -p "$CONFIG_DEST"

ln -sf "$HOME_SOURCE/.gitconfig" "$HOME/.gitconfig"
ln -sf "$HOME_SOURCE/.zshrc" "$HOME/.zshrc"
ln -sf "$CONFIG_SOURCE/nvim" "$CONFIG_DEST/nvim"
ln -sf "$CONFIG_SOURCE/hypr" "$CONFIG_DEST/hypr"

ln -sf "$CONFIG_SOURCE/zsh" "$CONFIG_DEST/zsh"

# Wezterm
ln -sf "$HOME_SOURCE/.wezterm.lua" "$HOME/.wezterm.lua"
ln -sf "$CONFIG_SOURCE/wezterm" "$CONFIG_DEST/wezterm"

# Tmux
ln -sf "$CONFIG_SOURCE/tmux" "$CONFIG_DEST/tmux"

# Starship
ln -sf "$CONFIG_SOURCE/starship.toml" "$CONFIG_DEST/starship.toml"

# Lazygit
ln -sf "$CONFIG_SOURCE/lazygit" "$CONFIG_DEST/lazygit"

# Ironbar
ln -sf "$CONFIG_SOURCE/ironbar" "$CONFIG_DEST/ironbar"


# Pi (LLM agent)
mkdir -p "$HOME/.pi/agent"
for item in "$HOME_SOURCE/.pi/agent"/*; do
  ln -sf "$item" "$HOME/.pi/agent/$(basename "$item")"
done
