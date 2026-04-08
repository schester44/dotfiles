#!/usr/bin/env bash

set -euo pipefail

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$DOTFILES/bin:$PATH"

MAC="$DOTFILES/platform/macos"

# -----------------------------------------------------------
# Git
# -----------------------------------------------------------
echo "==> Configuring git"
read -rp "  Git user name: " GIT_USER_NAME
read -rp "  Git user email: " GIT_USER_EMAIL

if [[ -n ${GIT_USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [[ -n ${GIT_USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

# -----------------------------------------------------------
# Homebrew
# -----------------------------------------------------------
echo "==> Checking for Homebrew"
if ! command -v brew &>/dev/null; then
  echo "  -> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "  -> Homebrew already installed"
fi

echo "==> Installing Homebrew packages"
source "$MAC/homebrew/brew.sh"

# -----------------------------------------------------------
# Shared symlinks (cross-platform configs)
# -----------------------------------------------------------
echo "==> Linking shared dotfiles"

HOME_SOURCE="$DOTFILES/home"
CONFIG_SOURCE="$HOME_SOURCE/.config"
CONFIG_DEST="$HOME/.config"

mkdir -p "$CONFIG_DEST"

ln -sf "$HOME_SOURCE/.gitconfig" "$HOME/.gitconfig"
ln -sf "$HOME_SOURCE/.zshrc" "$HOME/.zshrc"
ln -sf "$CONFIG_SOURCE/nvim" "$CONFIG_DEST/nvim"
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

# Pi (LLM agent)
mkdir -p "$HOME/.pi/agent"
for item in "$HOME_SOURCE/.pi/agent"/*; do
  [ -e "$item" ] && ln -sf "$item" "$HOME/.pi/agent/$(basename "$item")"
done

# -----------------------------------------------------------
# macOS-specific symlinks (aerospace, sketchybar)
# -----------------------------------------------------------
echo "==> Linking macOS configs"
"$MAC/link.sh"

# -----------------------------------------------------------
# npm global packages
# -----------------------------------------------------------
echo "==> Installing global npm packages"
if command -v npm &>/dev/null; then
  xargs < "$DOTFILES/system/packages/npm.txt" npm install -g
else
  echo "  -> npm not found, skipping global packages"
fi

# -----------------------------------------------------------
# Fonts
# -----------------------------------------------------------
echo "==> Installing fonts"
FONT_DIR="$HOME/Library/Fonts"
mkdir -p "$FONT_DIR"
unzip -o "$DOTFILES/system/fonts/fonts.zip" -d "$FONT_DIR"

# -----------------------------------------------------------
# macOS defaults (Finder, Dock, inputs, etc.)
# -----------------------------------------------------------
echo "==> Applying macOS defaults"
"$MAC/setup.sh"

echo ""
echo "==> Done! Restart your terminal (or run 'exec zsh') to pick up changes."
