#!/bin/bash

alias gpoh="git push origin head"
alias git-date='git for-each-ref --sort=-committerdate refs/heads/ | head -n 50'
alias git-rm-branches="git-date | awk '{print $3}' | sed -e "s/^refs\/heads\///" | awk '$0 !~ /dev|master/' | xargs git branch -D"
alias gcd="git checkout dev"
alias gmd="git merge dev"
alias gs="git status"
