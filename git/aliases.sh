#!/bin/bash

git config --global alias.upstream '!git push -u origin HEAD'
git config --global alias.recent 'branch --sort=-committerdate --format="%(committerdate:relative)%09%(refname:short)"'


alias gpoh="git push origin head"
alias git-rm-branches="git-date | awk '{print $3}' | sed -e "s/^refs\/heads\///" | awk '$0 !~ /dev|master/' | xargs git branch -D"
alias gcd="git checkout dev"
alias gmd="git merge dev"
alias gs="git status"
alias gpod="git pull origin dev"
alias glast="git checkout @{-1}"
