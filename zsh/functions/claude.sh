claude-session() {
	local session_name="$1"

	if [[ -z "$session_name" ]]; then
		echo "Usage: claude-session <session-name>"
		return 1
	fi

	local current_dir
	current_dir="$(pwd)"

	local worktree_base="$current_dir/../claude-sessions"
	mkdir -p "$worktree_base"

	local repo_root
	repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)" || {
		echo "❌ Not inside a Git repository."
		return 1
	}

	local base_branch
	if git -C "$repo_root" rev-parse --verify origin/main >/dev/null 2>&1; then
		base_branch="main"
	elif git -C "$repo_root" rev-parse --verify origin/master >/dev/null 2>&1; then
		base_branch="master"
	else
		echo "❌ Neither origin/main nor origin/master exists."
		return 1
	fi

	local new_branch="claude/$session_name"
	local worktree_path="$worktree_base/$session_name"

	echo "📁 Creating worktree from '$base_branch' at: $worktree_path"
	git -C "$repo_root" fetch origin "$base_branch"

	git -C "$repo_root" worktree add -b "$new_branch" "$worktree_path" "origin/$base_branch"

	echo "✅ Worktree created at: $worktree_path"
	echo "➡️  Branch: $new_branch"
}
