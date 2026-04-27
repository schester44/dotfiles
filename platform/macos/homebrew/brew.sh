#!/bin/bash

brew analytics off

brew install postgresql
brew install fzf
brew install jq

brew install --cask 1password
brew install --cask bitwarden
brew install --cask google-chrome
brew install --cask spotify

brew install --cask raycast
brew install --cask syncthing

# Bash scripting
brew install shfmt
brew install shellcheck

brew install --cask postman
brew install --cask tableplus
brew install --cask imageoptim

brew install sketchybar
brew install sesh
brew install lazygit
brew install neovim
brew install tmux
brew install starship
brew install wezterm
brew install neovim-remote
brew install git-delta

brew tap heroku/brew

brew install heroku
brew install yarn
brew install cmake
brew install nvm
brew install jordanbaird-ice

brew install ripgrep
brew install fd
brew install bat
brew install eza
brew install yazi
brew install zoxide
brew install gh
brew install gum
brew install tree-sitter-cli
brew install cloudflared
brew install zsh-autosuggestions
brew install zsh-syntax-highlighting

brew install --cask cleanshot
brew install --cask nikitabobko/tap/aerospace
brew install --cask firefox
brew install --cask obsidian
brew install --cask chatgpt
brew install --cask karabiner-elements
brew install --cask hazeover
brew install --cask screen-studio

# Dev dependencies

# The following are for node-canvas
# Ref: https://www.npmjs.com/package/canvas
brew install pkg-config
brew install cairo
brew install pango
brew install libpng
brew install jpeg
brew install giflib
brew install librsvg

# Launchd configuration
brew services start postgresql
