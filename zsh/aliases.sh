#!/bin/bash

alias ww="cd ~/work"

# Networking
alias pubip='curl ipv4.icanhazip.com'
alias ip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Yarn
alias yst="yarn start:test"
alias ys="yarn start"
alias yt="yarn test:watch:fast"
alias rel="sh ~/my-releases.sh"
alias ytu="yarn test:unfiltered:fast --watch --watch-files src"

# Misc
function kport {
lsof -i :"$1" |awk 'NR > 1 {print $2}' |xargs kill -15
}

# Random
alias prdb="prdb.sh"
alias e="nvim"


alias ls="eza --icons=always"

eval "$(zoxide init zsh)"
alias cd="z"



prodcon() {
    if [[ "$1" == "--log" ]]; then
        # Log output to a file with a timestamped filename

	DATE="$(date +"%Y%m%d%H%M")"

	LOG_PATH="~/logs/console/$DATE.log"
	echo "Starting console with log $LOG_PATH"
        heroku run yarn workspace api console --app obie-private-rm-production 2>&1 | tee "/Users/schester/logs/console/$DATE.log"
    else
        # Run without logging
        heroku run yarn workspace api console --app obie-private-rm-production
    fi
}

