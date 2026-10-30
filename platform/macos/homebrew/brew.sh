#!/bin/bash

brew analytics off

# Third-party taps must be trusted before Homebrew will install from them
brew trust --tap felixkratz/formulae acsandmann/tap
brew tap FelixKratz/formulae

# Shell & CLI
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install starship
brew install fzf
brew install ripgrep
brew install fd
brew install bat
brew install eza
brew install yazi
brew install zoxide
brew install jq
brew install gum
brew install gh
brew install git-delta
brew install lazygit
brew install tmux
brew install ffmpeg
brew install cloudflared
brew install awscli
brew install gogcli

# Editor
brew install neovim
brew install neovim-remote
brew install tree-sitter-cli

# Dev
brew install nvm
brew install yarn
brew install cmake
brew install postgresql@18
brew install shfmt
brew install shellcheck

# Secrets (rbw CLI; see home/.config/zsh/secrets.zsh)
brew install rbw
brew install pinentry-mac

# Vault sync (scripts/vault-sync)
brew install fswatch

# Window management & bar
brew install acsandmann/tap/rift
brew install sketchybar
brew install lua

# Apps
brew install --cask wezterm@nightly
brew install --cask 1password
brew install --cask bitwarden
brew install --cask raycast
brew install --cask karabiner-elements
brew install --cask jordanbaird-ice
brew install --cask firefox
brew install --cask obsidian
brew install --cask chatgpt
brew install --cask spotify
brew install --cask postman
brew install --cask tableplus
brew install --cask imageoptim
brew install --cask cleanshot
brew install --cask screen-studio

# Fonts
brew install --cask font-jetbrains-mono-nerd-font

# Services
brew services start postgresql@18
