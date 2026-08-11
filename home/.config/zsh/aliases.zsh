alias e="nvim"

alias dot="e ~/.dotfiles"

# Networking
alias pubip='curl ipv4.icanhazip.com'

# Git
[ -f ~/.config/zsh/aliases/git.zsh ] && source ~/.config/zsh/aliases/git.zsh

# File system
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

# Navigation
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
fi
