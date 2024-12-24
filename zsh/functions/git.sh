# Fuzzy search Git branches in a repo
# looks for local and remote branches
# Useage gfb [F]ind [B]ranch
gfb() {
	branches=$(git branch --sort=-committerdate --format="%(refname:short)")
	branch=$(echo "$branches" | fzf-tmux -p)

	if [ -n "$branch" ]; then
		git checkout $branch
	fi
}
