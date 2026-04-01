#!/usr/bin/env bash
set -euo pipefail


echo "==> Installing pacman packages"
sudo pacman -S --needed - < "$DOTFILES/system/packages/pacman.txt"

echo "==> Installing AUR packages"

if ! command -v yay &> /dev/null; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
fi

yay -S --needed - < "$DOTFILES/system/packages/aur.txt"
