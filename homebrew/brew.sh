#!/bin/bash

# Install binaries

brew install postgresql
brew install fzf
brew install jq

# Install Apps

## Must haves
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask firefox-developer-edition
brew install --cask google-chrome
brew install --cask spotify
brew install --cask bitwarden
brew install --cask raycast

## Dev apps
brew install --cask iTerm2
brew install --cask postman
brew install --cask visual-studio-code
brew install --cask tableplus
brew install yarn
brew install cmake

# Launchd configuration
brew services start postgresql

