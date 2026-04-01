#!/usr/bin/env bash

set -euo pipefail

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$DOTFILES/bin:$PATH"

GIT_CACHE="/tmp/dotfiles-git-config"

if [[ "${1:-}" == "--reset-git" ]] || [[ ! -f "$GIT_CACHE" ]]; then
  echo "==> Configuring git"
  read -rp "  Git user name: " GIT_USER_NAME
  read -rp "  Git user email: " GIT_USER_EMAIL
  echo "GIT_USER_NAME=$GIT_USER_NAME" >"$GIT_CACHE"
  echo "GIT_USER_EMAIL=$GIT_USER_EMAIL" >>"$GIT_CACHE"
else
  echo "==> Loading git config from cache ($GIT_CACHE)"
  echo "    (run with --reset-git to re-enter)"
  source "$GIT_CACHE"
fi

export GIT_USER_NAME
export GIT_USER_EMAIL

echo "==> Installing packages"
"$DOTFILES/install/install-packages.sh"

echo "==> Linking files"
"$DOTFILES/install/link.sh"

echo "==> Setting up services"
"$DOTFILES/install/setup-services.sh"

echo "==> Installing global npm packages"
xargs -a "$DOTFILES/system/packages/npm.txt" sudo npm install -g

echo "==> Installing fonts"
mkdir -p ~/.local/share/fonts
unzip -o "$DOTFILES/system/fonts/fonts.zip" -d ~/.local/share/fonts/
fc-cache -f

echo "==> Switching shell to zsh"
chsh -s $(which zsh)

echo "==> Configuring services"
"$DOTFILES/install/config/init.sh"

gum style \
  --border double \
  --border-foreground 212 \
  --padding "1 2" \
  --margin "1 0" \
  --bold \
  "✅ Dotfiles installed successfully!" \
  "" \
  "Please log out and log back in for zsh to take effect."
