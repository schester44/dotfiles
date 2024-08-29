#!/bin/bash

alias ww="cd ~/work"

# Networking
alias pubip='curl ipv4.icanhazip.com'
alias ip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"


# Yarn
alias yst="yarn start:test"
alias ys="yarn start"
alias yt="yarn test"
alias rel="sh ~/my-releases.sh"


# Misc
function kport {
lsof -i :"$1" |awk 'NR > 1 {print $2}' |xargs kill -15
}

# Random
alias prdb="prdb.sh"
