tn() {
	# Join all arguments to allow spaces in task names without quotes
	local session_name="$*"

	if [[ -z "$session_name" ]]; then
		echo "Usage: t-new <session-name>"
		return 1
	fi

	local repo_root
	repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)" || {
		echo "❌ Not inside a Git repository."
		return 1
	}

	local repo_name
	repo_name="$(basename "$repo_root")"

	local worktree_base="$HOME/worktrees/$repo_name"

	# Create the worktree directory if it doesn't exist
	if [[ ! -d "$worktree_base" ]]; then
		echo "📁 Creating worktree directory: $worktree_base"
		mkdir -p "$worktree_base"
	fi

	local base_branch
	if git -C "$repo_root" rev-parse --verify origin/main >/dev/null 2>&1; then
		base_branch="main"
	elif git -C "$repo_root" rev-parse --verify origin/master >/dev/null 2>&1; then
		base_branch="master"
	else
		echo "❌ Neither origin/main nor origin/master exists."
		return 1
	fi

	# Replace spaces with dashes for branch name (git doesn't allow spaces in branch names)
	local new_branch="${session_name// /_}"
	local worktree_path="$worktree_base/$session_name"

	echo "📁 Creating worktree from '$base_branch' at: $worktree_path"

	if ! git -C "$repo_root" fetch origin "$base_branch"; then
		echo "❌ Failed to fetch from origin"
		return 1
	fi

	if ! git -C "$repo_root" worktree add -b "$new_branch" "$worktree_path" "origin/$base_branch"; then
		echo "❌ Failed to create worktree (branch may already exist or path is in use)"
		return 1
	fi

	echo "✅ Worktree created at: $worktree_path"
	echo "➡️  Branch: $new_branch"

	# Check for and run setup script if it exists
	local setup_script="$repo_root/.agents/worktree-setup.sh"
	if [[ -f "$setup_script" ]]; then
		echo "🔧 Running worktree setup script..."
		if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$session_name" bash "$setup_script"); then
			echo "✅ Setup script completed successfully"
		else
			echo "⚠️  Setup script failed with exit code $?"
		fi
	else
		echo "ℹ️  No setup script found at .agents/worktree-setup.sh"
	fi

	# Open a new WezTerm tab with the task name
	if command -v wezterm &>/dev/null; then
		echo "🪟 Opening new WezTerm tab..."
		local pane_id
		pane_id=$(wezterm cli spawn --cwd "$worktree_path" -- zsh -i -c "e; exec zsh")
		if [[ -n "$pane_id" ]]; then
			wezterm cli set-tab-title --pane-id "$pane_id" "$session_name"
			# Small delay to avoid git config lock contention
			sleep 0.5
			wezterm cli split-pane --right --pane-id "$pane_id" -- zsh -i -c "pi"
		fi
	fi
}

# Helper function to get worktree task names (excludes main repo)
_t-get-worktrees() {
	local repo_root="$1"
	git -C "$repo_root" worktree list --porcelain | awk '
		/^worktree / {
			path = substr($0, 10)
			# Skip the main repo (first worktree is always main)
			if (NR > 1 || path !~ /\.git$/) {
				n = split(path, parts, "/")
				# Only include worktrees under ~/worktrees/
				if (path ~ /\/worktrees\//) {
					print parts[n]
				}
			}
		}
	'
}

tl() {
	local repo_root
	repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)" || {
		echo "❌ Not inside a Git repository."
		return 1
	}

	local current_dir="$(pwd)"

	echo "📋 Active Tasks (Worktrees):"
	echo ""

	local i=1
	git -C "$repo_root" worktree list | while IFS= read -r line; do
		local worktree_path=$(echo "$line" | awk '{print $1}')
		local branch=$(echo "$line" | grep -oE '\[.*\]' | tr -d '[]')

		# Skip the main repo worktree (not under worktrees/)
		if [[ ! "$worktree_path" =~ /worktrees/ ]]; then
			continue
		fi

		# Check if this is the current worktree
		if [[ "$current_dir" == "$worktree_path"* ]]; then
			echo "➡️  [$i] $worktree_path ($branch) [current]"
		else
			echo "   [$i] $worktree_path ($branch)"
		fi
		((i++))
	done
}

tg() {
	local input="$1"

	if [[ -z "$input" ]]; then
		echo "❌ Usage: tg <number|name>"
		return 1
	fi

	local repo_root
	repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)" || {
		echo "❌ Not inside a Git repository."
		return 1
	}

	local i=1
	local target_path=""

	while IFS= read -r line; do
		local worktree_path=$(echo "$line" | awk '{print $1}')

		# Skip the main repo worktree (not under worktrees/)
		if [[ ! "$worktree_path" =~ /worktrees/ ]]; then
			continue
		fi

		# Match by number
		if [[ "$input" =~ ^[0-9]+$ ]] && [[ "$i" -eq "$input" ]]; then
			target_path="$worktree_path"
			break
		fi

		# Match by name (directory name contains input)
		local dir_name=$(basename "$worktree_path")
		if [[ "$dir_name" == *"$input"* ]]; then
			target_path="$worktree_path"
			break
		fi

		((i++))
	done < <(git -C "$repo_root" worktree list)

	if [[ -n "$target_path" ]]; then
		cd "$target_path"
		echo "📂 Changed to: $target_path"
	else
		echo "❌ No worktree found matching: $input"
		return 1
	fi
}

td() {
	# Join all arguments to allow spaces in task names without quotes
	local task_input="$*"

	local repo_root
	repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)" || {
		echo "❌ Not inside a Git repository."
		return 1
	}

	local worktree_path
	local current_dir="$(pwd)"
	local task_name

	# If task input provided, check if it's a number or a name
	if [[ -n "$task_input" ]]; then
		# Check if input is a number
		if [[ "$task_input" =~ ^[0-9]+$ ]]; then
			# Get the task name by index
			local worktrees=("${(@f)$(_t-get-worktrees "$repo_root")}")
			if (( task_input < 1 || task_input > ${#worktrees[@]} )); then
				echo "❌ Invalid task number: $task_input (valid: 1-${#worktrees[@]})"
				return 1
			fi
			task_name="${worktrees[$task_input]}"
			echo "📌 Selected task: $task_name"
		else
			task_name="$task_input"
		fi

		# Look for worktree matching the task name using --porcelain for reliable parsing
		worktree_path=$(git -C "$repo_root" worktree list --porcelain | awk -v task="$task_name" '
			/^worktree / {
				path = substr($0, 10)
				n = split(path, parts, "/")
				if (parts[n] == task) {
					print path
					exit
				}
			}
		')

		if [[ -z "$worktree_path" ]]; then
			echo "❌ No worktree found with name: $task_name"
			return 1
		fi
	else
		# No argument provided, use current directory
		local git_dir
		git_dir="$(git rev-parse --git-dir 2>/dev/null)"
		if [[ ! "$git_dir" =~ \.git/worktrees ]]; then
			echo "❌ Not inside a git worktree. Provide a task name as argument."
			return 1
		fi
		worktree_path="$current_dir"
	fi

	# Check for and run teardown script if it exists
	local teardown_script="$repo_root/.agents/worktree-teardown.sh"
	if [[ -f "$teardown_script" ]]; then
		echo "🔧 Running teardown script..."
		local worktree_name=$(basename "$worktree_path")
		if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$worktree_name" bash "$teardown_script"); then
			echo "✅ Teardown script completed successfully"
		else
			echo "⚠️  Teardown script failed with exit code $?"
			echo "❌ Aborting worktree removal due to teardown failure"
			return 1
		fi
	fi

	# Get the branch name for this worktree before removing it
	local branch_name
	branch_name=$(git -C "$repo_root" worktree list --porcelain | awk -v path="$worktree_path" '
		$1 == "worktree" && $2 == path { capture = 1 }
		capture && $1 == "branch" { sub("refs/heads/", "", $2); print $2; exit }
	')

	# If we're currently in the worktree being removed, move out of it
	if [[ "$current_dir" == "$worktree_path"* ]]; then
		cd ..
	fi

	echo "🗑️  Removing worktree at: $worktree_path"
	if git -C "$repo_root" worktree remove "$worktree_path" --force; then
		echo "✅ Worktree removed successfully"

		# Remove the directory if it still exists
		if [[ -d "$worktree_path" ]]; then
			echo "🗑️  Removing directory: $worktree_path"
			rm -rf "$worktree_path"
		fi

		# Delete the branch if we found one
		if [[ -n "$branch_name" ]]; then
			echo "🗑️  Deleting branch: $branch_name"
			if git -C "$repo_root" branch -D "$branch_name"; then
				echo "✅ Branch deleted successfully"
			else
				echo "⚠️  Failed to delete branch"
			fi
		fi
	else
		echo "⚠️  Failed to remove worktree"
		return 1
	fi
}
