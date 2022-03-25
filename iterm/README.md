# iTerm 2

## Installation
Install using homebrew

## Sync Configs

```
# Specify the preferences directory
defaultls write com.googlecode.iterm2 PrefsCustomFolder -string "~/.dotfiles/iTerm/settings"

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googleccode.iterm2 LoadPreferencesFromCustomFolder -bool true
```
