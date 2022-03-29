#!/bin/bash

# Install binaries

brew install postgresql
brew install fzf
brew install jq

# Install Apps

## Must haves
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask bitwarden
brew install --cask authy

brew install --cask google-chrome

brew install --cask spotify

brew install --cask raycast
brew install --cask syncthing
brew install --cask rocket

## Dev apps
brew install --cask iTerm2
brew install --cask postman
brew install --cask visual-studio-code
brew install --cask tableplus
brew install --cask imageoptim
brew install --cask proxyman

brew tap heroku/brew

brew install heroku
brew install yarn
brew install cmake
brew install nvm

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

