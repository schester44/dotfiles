alias e="nvim"

alias dot="e ~/.dotfiles"

# Networking
alias pubip='curl ipv4.icanhazip.com'

# Git
alias g="lazygit"
alias gs="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gc="git commit"
alias gcmsg="git commit -m"
alias gca="git commit --amend"
alias ga="git add"
alias gaa="git add --all"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline"
alias gp="git push"
alias gpl="git pull"
alias gb="git branch"
alias gst="git stash"
alias gstp="git stash pop"
alias grb="git rebase"
alias grbi="git rebase -i"
alias gpsu="git_set_upstream"
alias gpoh="git push origin head"
alias gcm="git checkout main"
alias gmm="git merge main"
alias gml="git merge @{-1}"
alias gpm="git pull origin main"
alias glast="git checkout @{-1}"
alias gwl="git worktree list"
alias gwr="git worktree remove"
alias gce="git commit --allow-empty -m"
alias ghd="gh dash"
alias git-rm-branches="git branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)' | awk '{print \$3}' | sed -e 's/^refs\/heads\///' | awk '\$0 !~ /dev|main/' | xargs git branch -D"

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
