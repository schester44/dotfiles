#!/bin/bash

alias ww="cd ~/work"

# Networking
alias pubip='curl ipv4.icanhazip.com'
alias ip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Yarn
alias yst="yarn start:test"
alias ys="yarn start"
alias yt="yarn test:watch"
alias ytf="yarn test:watch:fast"
alias ytu="yarn test:unfiltered --watch --watch-files src"
alias ytuf="yarn test:unfiltered:fast"
# Random
alias prdb="prdb.sh"

# Misc
function kport {
  lsof -i :"$1" | awk 'NR > 1 {print $2}' | xargs kill -15
}

# System
eval "$(zoxide init zsh)"
alias cd="z"
alias ls="eza --icons=always"
