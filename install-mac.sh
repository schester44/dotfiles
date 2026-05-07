#!/usr/bin/env bash

set -euo pipefail

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$DOTFILES/bin:$PATH"

MAC="$DOTFILES/platform/macos"

# -----------------------------------------------------------
# Homebrew + gum (install early for pretty output)
# -----------------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew install gum 2>/dev/null

# -----------------------------------------------------------
# Homebrew packages
# -----------------------------------------------------------
# gum spin --spinner dot --title "Installing Homebrew packages..." -- bash -c "source '$MAC/homebrew/brew.sh'"

# -----------------------------------------------------------
# Shared symlinks (cross-platform configs)
# -----------------------------------------------------------
gum style --bold "🔗 Linking shared dotfiles"

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
# macOS-specific symlinks (aerospace, sketchybar, karabiner)
# -----------------------------------------------------------
gum style --bold "🔗 Linking macOS configs"
"$MAC/link.sh"

# -----------------------------------------------------------
# GitHub authentication
# -----------------------------------------------------------
if ! gh auth status &>/dev/null; then
  gum style --bold "🔐 Authenticating with GitHub"
  gh auth login
else
  gum style --bold "🔐 GitHub already authenticated"
fi

# -----------------------------------------------------------
# Node (via nvm)
# -----------------------------------------------------------
gum spin --spinner dot --title "Installing Node via nvm..." -- bash -c '
  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"
  nvm install --lts
'

# -----------------------------------------------------------
# npm global packages
# -----------------------------------------------------------
if command -v npm &>/dev/null; then
  gum spin --spinner dot --title "Installing global npm packages..." -- bash -c "xargs < '$DOTFILES/system/packages/npm.txt' npm install -g"
else
  gum style --foreground 208 "⚠️  npm not found, skipping global packages"
fi

# -----------------------------------------------------------
# Fonts
# -----------------------------------------------------------
gum spin --spinner dot --title "Installing fonts..." -- bash -c '
  FONT_DIR="$HOME/Library/Fonts"
  mkdir -p "$FONT_DIR"
  unzip -o "'"$DOTFILES"'/system/fonts/fonts.zip" -d "$FONT_DIR"
  curl -fsSL -o "$FONT_DIR/sketchybar-app-font.ttf" \
    "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf"
'

# -----------------------------------------------------------
# macOS defaults (Finder, Dock, inputs, etc.)
# -----------------------------------------------------------
gum style --bold "🍎 Applying macOS defaults"
"$MAC/setup.sh"

# -----------------------------------------------------------
# Dottt (manual DMG install)
# -----------------------------------------------------------
gum spin --spinner dot --title "Installing Dottt..." -- bash -c '
  DOTTT_DMG="/tmp/dottt.dmg"
  curl -fsSL -o "$DOTTT_DMG" "https://github.com/dottt-app/dottt-releases/releases/download/v0.12.0/dottt-app-0.12.0.dmg"
  hdiutil attach "$DOTTT_DMG" -nobrowse -quiet
  cp -R "/Volumes/dottt-app-0.12.0/Dottt.app" /Applications/ 2>/dev/null || cp -R /Volumes/dottt-app*/Dottt.app /Applications/
  hdiutil detach "/Volumes/dottt-app-0.12.0" -quiet 2>/dev/null || true
  rm -f "$DOTTT_DMG"
'

# -----------------------------------------------------------
# Services (sketchybar, aerospace)
# -----------------------------------------------------------
gum style --bold "🚀 Starting services"
brew services start sketchybar
open -a AeroSpace

# -----------------------------------------------------------
# Done
# -----------------------------------------------------------
gum style \
  --border double \
  --border-foreground 212 \
  --padding "1 2" \
  --margin "1 0" \
  --bold \
  "✅ Dotfiles installed successfully!" \
  "" \
  "Manual steps:" \
  "" \
  "  1. Remap Caps Lock → Control" \
  "     System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys" \
  "" \
  "  2. Sign into apps" \
  "     1Password, Raycast, Spotify, Firefox, Chrome, Obsidian" \
  "" \
  "  3. Restart your terminal (or run 'exec zsh')"
