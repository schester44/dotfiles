#!/bin/bash

brew analytics off

brew install postgresql
brew install fzf
brew install jq
brew install kubectl

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
brew install --cask proxyman

brew install neovim
brew install wezterm
brew install neovim-remote

brew tap heroku/brew

brew install heroku
brew install yarn
brew install cmake
brew install nvm
brew install jordanbaird-ice

# Dev dependencies

# The following are for node-canvas
# Ref: https://www.npmjs.com/package/canvas
brew install pkg-config
brew install cairo
brew install pango
brew install libpng
brew install jpeg
brew install giflib
brewl install librsvg

# Launchd configuration
brew services start postgresql
