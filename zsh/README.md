# ZSH


## Installation

```
# Install `oh-my-zsh` (http://ohmyz.sh/)
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# Symlink `.zshrc`
ln -s ~/.dotfiles/zsh/zshrc.symlink ~/.zshrc
```

Symlink theme

```
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
```

Symlink your private files

Use syncthing to symlink your .ssh directory to ~/.ssh
