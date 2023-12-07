#!/bin/bash


git_set_upstream() {
    local branch=$(git branch --show-current)

    git branch --set-upstream-to="origin/$branch" "$branch"
}


git config --global alias.upstream '!git push -u origin HEAD'
git config --global alias.recent 'branch --sort=-committerdate --format="%(committerdate:relative)%09%(refname:short)"'

alias gpsu="git_set_upstream"
alias gpoh="git push origin head"
alias git-rm-branches="git-date | awk '{print $3}' | sed -e "s/^refs\/heads\///" | awk '$0 !~ /dev|master/' | xargs git branch -D"
alias gcm="git checkout main"
alias gmm="git merge main"
alias gs="git status"
alias gpm="git pull origin main"
alias glast="git checkout @{-1}"
alias g="lazygit"
