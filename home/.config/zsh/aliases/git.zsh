# Git aliases

# Core
alias g="lazygit"
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline"
alias glo="git log --oneline --graph --decorate -20"

# Branching
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcm="git checkout main"
alias glast="git checkout @{-1}"

# Staging
alias ga="git add"
alias gaa="git add --all"

# Committing
alias gc="git commit"
alias gcmsg="git commit -m"
alias gca="git commit --amend"
alias gcane="git commit --amend --no-edit"
alias gce="git commit --allow-empty -m"

# Push / Pull
alias gp="git pull"
alias gpp="git push origin head"
alias gpm="git pull --rebase origin main"

# Rebase / Merge
alias gr="git rebase"
alias grr="git rebase"
alias grbi="git rebase -i"
alias grc="git rebase --continue"
alias gra="git rebase --abort"
alias gmm="git merge main"
alias gml="git merge @{-1}"
alias gcp="git cherry-pick"

# Stash
alias gst="git stash"
alias gstp="git stash pop"

# Worktree
alias gwl="git worktree list"
alias gwr="git worktree remove"

# Upstream
alias gpsu="git_set_upstream"

# GitHub
alias ghd="gh dash"

# Push
alias gpf="git push --force-with-lease"

# Cleanup
alias git-rm-branches="git branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)' | awk '{print \$3}' | sed -e 's/^refs\/heads\///' | awk '\$0 !~ /dev|main/' | xargs git branch -D"
