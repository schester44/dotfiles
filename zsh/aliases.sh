alias ww="cd ~/work"

# Networking
alias pubip='curl ipv4.icanhazip.com'
alias ip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Git
alias gpoh="git push origin head"
alias git-date='git for-each-ref --sort=-committerdate refs/heads/ | head -n 50'
alias git-rm-branches="git-date | awk '{print $3}' | sed -e "s/^refs\/heads\///" | awk '$0 !~ /dev|master/' | xargs git branch -D"
alias gcd="git checkout dev"
alias gmd="git merge dev"

# Yarn
alias yst="yarn start:test"
alias ys="yarn start"
alias yt="yarn test"

# Misc
function kport {
lsof -i :"$1" |awk 'NR > 1 {print $2}' |xargs kill -15
}
