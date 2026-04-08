# ─── gum helpers ──────────────────────────────────────────────────────────────

_wt_info()  { gum log --level info  "$@"; }
_wt_warn()  { gum log --level warn  "$@"; }
_wt_error() { gum log --level error "$@"; }
_wt_ok()    { gum log --level info  --prefix "✓" "$@"; }

_wt_header() {
  gum style --bold --foreground 212 " $1"
}

_wt_dim() {
  gum style --faint "$1"
}

# ─── repo helpers ─────────────────────────────────────────────────────────────

_wt_repo_root() {
  git -C . rev-parse --show-toplevel 2>/dev/null
}

_wt_repo_name() {
  basename "$(_wt_repo_root)"
}

_wt_worktree_base() {
  echo "$HOME/worktrees/$(_wt_repo_name)"
}

_wt_default_branch() {
  local repo_root="$1"
  if git -C "$repo_root" rev-parse --verify origin/main >/dev/null 2>&1; then
    echo "main"
  elif git -C "$repo_root" rev-parse --verify origin/master >/dev/null 2>&1; then
    echo "master"
  else
    return 1
  fi
}

# ─── open in wezterm ──────────────────────────────────────────────────────────

_wt_open_wezterm() {
  local worktree_path="$1"
  local session_name="$2"

  command -v wezterm &>/dev/null || return 0

  local current_pane="$WEZTERM_PANE"
  local reuse_tab=false

  if [[ -n "$current_pane" ]]; then
    local current_tab_id
    current_tab_id=$(wezterm cli list --format json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for p in data:
    if p.get('pane_id') == $current_pane:
        print(p.get('tab_id', ''))
        break
" 2>/dev/null)
    if [[ -n "$current_tab_id" ]]; then
      local pane_count
      pane_count=$(wezterm cli list --format json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(sum(1 for p in data if p.get('tab_id') == $current_tab_id))
" 2>/dev/null)
      [[ "$pane_count" -eq 1 ]] && reuse_tab=true
    fi
  fi

  if [[ "$reuse_tab" == true ]]; then
    _wt_info "Reusing current tab"
    wezterm cli set-tab-title "$session_name"
    cd "$worktree_path" || return 1
    e
    wezterm cli split-pane --right --cwd "$worktree_path" -- zsh -i -c "pi"
  else
    _wt_info "Opening new tab"
    local pane_id
    pane_id=$(wezterm cli spawn --cwd "$worktree_path" -- zsh -i -c "e; exec zsh")
    if [[ -n "$pane_id" ]]; then
      wezterm cli set-tab-title --pane-id "$pane_id" "$session_name"
      sleep 0.5
      wezterm cli split-pane --right --pane-id "$pane_id" -- zsh -i -c "pi"
    fi
  fi
}

# ─── run setup script ────────────────────────────────────────────────────────

_wt_run_setup() {
  local repo_root="$1"
  local worktree_path="$2"
  local session_name="$3"
  shift 3
  local setup_args=("$@")

  local setup_script="$repo_root/.agents/worktree-setup.sh"
  [[ -f "$setup_script" ]] || return 0

  _wt_info "Running worktree setup script..."
  if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$session_name" bash "$setup_script" "${setup_args[@]}"); then
    _wt_ok "Setup complete"
  else
    _wt_warn "Setup script failed with exit code $?"
  fi
}

# ─── main command ─────────────────────────────────────────────────────────────

wt() {
  local cmd="$1"
  shift 2>/dev/null

  case "$cmd" in
    new|n)       _wt_new "$@" ;;
    checkout|co) _wt_checkout "$@" ;;
    list|ls|l)   _wt_list "$@" ;;
    go|g)        _wt_go "$@" ;;
    delete|del|d|rm) _wt_delete "$@" ;;
    setup|s)     _wt_setup "$@" ;;
    help|--help|-h|"") _wt_help ;;
    *)
      _wt_error "Unknown command: $cmd"
      _wt_help
      return 1
      ;;
  esac
}

# ─── help ─────────────────────────────────────────────────────────────────────

_wt_help() {
  gum format <<'EOF'
# wt — worktree manager

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `new <name> [base]` | `n` | Create a new worktree (new branch) |
| `checkout <branch>` | `co` | Worktree from existing branch |
| `list` | `ls`, `l` | List all worktrees |
| `go <num\|name>` | `g` | Jump to a worktree |
| `delete [num\|name]` | `d`, `rm` | Delete a worktree |
| `setup` | `s` | Run setup script in current worktree |

## Examples

```bash
wt new my-feature            # branch off main
wt new my-feature develop    # branch off origin/develop
wt new my-feature .          # branch off current branch
wt co steve/ff-clean-up      # checkout existing branch
wt list                      # show worktrees
wt go 2                      # jump by number
wt go my-feature             # jump by name
wt delete                    # delete current
wt delete my-feature         # delete by name
```
EOF
}

# ─── new ──────────────────────────────────────────────────────────────────────

_wt_new() {
  local session_name="$1"
  local base_arg="$2"
  shift 2 2>/dev/null || shift 1 2>/dev/null
  local setup_args=("$@")

  if [[ -z "$session_name" ]]; then
    _wt_error "Usage: wt new <name> [base-branch] [setup-args...]"
    return 1
  fi

  local repo_root
  if ! repo_root="$(_wt_repo_root)"; then
    _wt_error "Not inside a Git repository"
    return 1
  fi

  local worktree_base
  worktree_base="$(_wt_worktree_base)"
  mkdir -p "$worktree_base"

  # Resolve base branch
  local base_branch
  if [[ -n "$base_arg" ]]; then
    if [[ "$base_arg" == "." ]]; then
      base_branch=$(git -C "$repo_root" branch --show-current 2>/dev/null)
      if [[ -z "$base_branch" ]]; then
        _wt_error "Not on a branch (detached HEAD?)"
        return 1
      fi
    else
      base_branch="$base_arg"
    fi
    if ! git -C "$repo_root" rev-parse --verify "origin/$base_branch" >/dev/null 2>&1; then
      _wt_error "origin/$base_branch does not exist"
      return 1
    fi
  else
    if ! base_branch="$(_wt_default_branch "$repo_root")"; then
      _wt_error "Neither origin/main nor origin/master exists. Specify a base branch."
      return 1
    fi
  fi

  local new_branch="${session_name// /_}"
  local worktree_path="$worktree_base/$session_name"

  _wt_header "Creating worktree"
  echo ""
  _wt_dim "  branch: $new_branch"
  _wt_dim "  base:   origin/$base_branch"
  _wt_dim "  path:   $worktree_path"
  echo ""

  if ! gum spin --title "Fetching origin/$base_branch..." -- \
    git -C "$repo_root" fetch origin "$base_branch"; then
    _wt_error "Failed to fetch from origin"
    return 1
  fi

  if ! git -C "$repo_root" worktree add -b "$new_branch" "$worktree_path" "origin/$base_branch" 2>&1; then
    _wt_error "Failed to create worktree (branch may already exist or path is in use)"
    return 1
  fi

  _wt_ok "Worktree created"

  _wt_run_setup "$repo_root" "$worktree_path" "$session_name" "${setup_args[@]}"
  _wt_open_wezterm "$worktree_path" "$session_name"
}

# ─── checkout ─────────────────────────────────────────────────────────────────

_wt_checkout() {
  local branch="$1"
  shift 2>/dev/null
  local setup_args=("$@")

  if [[ -z "$branch" ]]; then
    _wt_error "Usage: wt checkout <existing-branch> [setup-args...]"
    return 1
  fi

  local repo_root
  if ! repo_root="$(_wt_repo_root)"; then
    _wt_error "Not inside a Git repository"
    return 1
  fi

  local worktree_base
  worktree_base="$(_wt_worktree_base)"
  mkdir -p "$worktree_base"

  # Fetch
  if ! gum spin --title "Fetching origin/$branch..." -- \
    git -C "$repo_root" fetch origin "+refs/heads/$branch:refs/remotes/origin/$branch" 2>/dev/null; then
    _wt_warn "Could not fetch origin/$branch (may only exist locally)"
  fi

  # Verify branch exists
  if ! git -C "$repo_root" rev-parse --verify "$branch" >/dev/null 2>&1 && \
     ! git -C "$repo_root" rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
    _wt_error "Branch '$branch' does not exist locally or on origin"
    return 1
  fi

  local session_name="${branch//\//-}"
  local worktree_path="$worktree_base/$session_name"
  local created_new=false

  # Check if a worktree already exists for this branch (by branch name)
  local existing_path
  existing_path=$(git -C "$repo_root" worktree list --porcelain | awk -v branch="refs/heads/$branch" '
    /^worktree / { path = substr($0, 10) }
    /^branch / && $2 == branch { print path; exit }
  ')

  if [[ -n "$existing_path" && -d "$existing_path" ]]; then
    _wt_info "Worktree already exists at $existing_path"
    worktree_path="$existing_path"
    session_name="$(basename "$existing_path")"
  else
    _wt_header "Creating worktree"
    echo ""
    _wt_dim "  branch: $branch"
    _wt_dim "  path:   $worktree_path"
    echo ""

    local add_output
    add_output=$(git -C "$repo_root" worktree add "$worktree_path" "$branch" 2>&1)
    local add_rc=$?

    if [[ $add_rc -ne 0 ]]; then
      # Parse existing worktree path from git error: "already used by worktree at '/path'"
      local error_path
      error_path=$(echo "$add_output" | sed -n "s/.*already used by worktree at '\\(.*\\)'.*/\\1/p")
      if [[ -n "$error_path" && -d "$error_path" ]]; then
        _wt_info "Worktree already exists at $error_path"
        worktree_path="$error_path"
        session_name="$(basename "$error_path")"
      else
        echo "$add_output"
        _wt_error "Failed to create worktree"
        return 1
      fi
    else
      _wt_ok "Worktree created"
      created_new=true
    fi
  fi

  # Fix detached HEAD if needed
  local current_branch
  current_branch=$(git -C "$worktree_path" branch --show-current 2>/dev/null)
  if [[ -z "$current_branch" ]]; then
    _wt_warn "Worktree is in detached HEAD state"
    if gum spin --title "Checking out $branch..." -- \
      git -C "$worktree_path" checkout "$branch" 2>&1; then
      _wt_ok "Now on branch $branch"
    else
      _wt_warn "Could not checkout branch (may need manual conflict resolution)"
    fi
  else
    _wt_dim "  branch: $current_branch"
  fi

  if [[ "$created_new" == true ]]; then
    _wt_run_setup "$repo_root" "$worktree_path" "$session_name" "${setup_args[@]}"
  fi

  _wt_open_wezterm "$worktree_path" "$session_name"
}

# ─── list ─────────────────────────────────────────────────────────────────────

_wt_list() {
  local repo_root
  if ! repo_root="$(_wt_repo_root)"; then
    _wt_error "Not inside a Git repository"
    return 1
  fi

  local current_dir
  current_dir="$(pwd)"

  _wt_header "Worktrees"
  echo ""

  local rows=()
  local i=1
  local wt_path branch name marker

  git -C "$repo_root" worktree list | while IFS= read -r line; do
    wt_path="${line%% *}"
    [[ "$wt_path" =~ /worktrees/ ]] || continue

    if [[ "$line" == *"["*"]"* ]]; then
      branch="${line##*\[}"
      branch="${branch%\]}"
    elif [[ "$line" == *"(detached HEAD)"* ]]; then
      branch="detached"
    else
      branch="unknown"
    fi

    name="${wt_path##*/}"
    marker=""
    [[ "$current_dir" == "$wt_path"* ]] && marker=" ●"

    rows+=("$i,$name,$branch$marker")
    ((i++))
  done

  if [[ ${#rows[@]} -eq 0 ]]; then
    _wt_dim "  No worktrees found"
    return 0
  fi

  printf '%s\n' "${rows[@]}" | gum table \
    --separator "," \
    --columns "#,Name,Branch" \
    --widths 4,30,50 \
    --border rounded \
    --print
}

# ─── go ───────────────────────────────────────────────────────────────────────

_wt_go() {
  local input="$1"
  local repo_root
  if ! repo_root="$(_wt_repo_root)"; then
    _wt_error "Not inside a Git repository"
    return 1
  fi

  # Build worktree list
  local options=()
  local paths=()
  local line wt_path branch name
  git -C "$repo_root" worktree list | while IFS= read -r line; do
    wt_path="${line%% *}"
    [[ "$wt_path" =~ /worktrees/ ]] || continue
    if [[ "$line" == *"["*"]"* ]]; then
      branch="${line##*\[}"
      branch="${branch%\]}"
    elif [[ "$line" == *"(detached HEAD)"* ]]; then
      branch="detached"
    else
      branch="unknown"
    fi
    name="${wt_path##*/}"
    options+=("$name  ($branch)")
    paths+=("$wt_path")
  done

  if [[ ${#options[@]} -eq 0 ]]; then
    _wt_error "No worktrees found"
    return 1
  fi

  # If no input, show interactive picker
  if [[ -z "$input" ]]; then
    local choice
    choice=$(printf '%s\n' "${options[@]}" | gum filter --header "Jump to worktree:" --height 15)
    [[ -z "$choice" ]] && return 0

    local idx
    for idx in {1..${#options[@]}}; do
      if [[ "${options[$idx]}" == "$choice" ]]; then
        cd "${paths[$idx]}" || return 1
        _wt_ok "Changed to ${paths[$idx]}"
        return 0
      fi
    done
    return 1
  fi

  # Direct lookup by number or name
  local i
  for i in {1..${#options[@]}}; do
    wt_path="${paths[$i]}"
    name="${wt_path##*/}"

    if [[ "$input" =~ ^[0-9]+$ ]] && [[ "$i" -eq "$input" ]]; then
      cd "$wt_path" || return 1
      _wt_ok "Changed to $wt_path"
      return 0
    fi

    if [[ "$name" == *"$input"* ]]; then
      cd "$wt_path" || return 1
      _wt_ok "Changed to $wt_path"
      return 0
    fi
  done

  _wt_error "No worktree found matching: $input"
  return 1
}

# ─── setup ────────────────────────────────────────────────────────────────────

_wt_setup() {
  local setup_args=("$@")
  local worktree_path
  worktree_path="$(pwd)"
  local worktree_name
  worktree_name="$(basename "$worktree_path")"

  local git_common_dir
  if ! git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)"; then
    _wt_error "Not inside a Git repository"
    return 1
  fi
  local repo_root
  repo_root="$(dirname "$git_common_dir")"

  local setup_script="$repo_root/.agents/worktree-setup.sh"
  if [[ ! -f "$setup_script" ]]; then
    _wt_error "No setup script found at .agents/worktree-setup.sh"
    return 1
  fi

  _wt_info "Running worktree setup script..."
  if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$worktree_name" bash "$setup_script" "${setup_args[@]}"); then
    _wt_ok "Setup complete"
  else
    _wt_error "Setup script failed with exit code $?"
    return 1
  fi
}

# ─── delete ───────────────────────────────────────────────────────────────────

_wt_delete() {
  local task_input="$*"

  local repo_root
  if ! repo_root="$(_wt_repo_root)"; then
    _wt_error "Not inside a Git repository"
    return 1
  fi

  local worktree_path
  local current_dir
  current_dir="$(pwd)"
  local task_name

  # No argument: interactive picker or current worktree
  if [[ -z "$task_input" ]]; then
    local git_dir
    git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    if [[ "$git_dir" =~ \.git/worktrees ]]; then
      worktree_path="$current_dir"
      task_name="$(basename "$worktree_path")"
    else
      # Interactive picker
      local options=()
      local paths=()
      local wt_path branch name

      git -C "$repo_root" worktree list | while IFS= read -r line; do
        wt_path="${line%% *}"
        [[ "$wt_path" =~ /worktrees/ ]] || continue

        if [[ "$line" == *"["*"]"* ]]; then
          branch="${line##*\[}"
          branch="${branch%\]}"
        elif [[ "$line" == *"(detached HEAD)"* ]]; then
          branch="detached"
        else
          branch="unknown"
        fi

        name="${wt_path##*/}"
        options+=("$name  ($branch)")
        paths+=("$wt_path")
      done

      if [[ ${#options[@]} -eq 0 ]]; then
        _wt_error "No worktrees found"
        return 1
      fi

      local choice
      choice=$(printf '%s\n' "${options[@]}" | gum filter --header "Delete which worktree?:" --height 15)
      [[ -z "$choice" ]] && return 0

      for idx in "${!options[@]}"; do
        if [[ "${options[$idx]}" == "$choice" ]]; then
          worktree_path="${paths[$idx]}"
          task_name="$(basename "$worktree_path")"
          break
        fi
      done
      # zsh 1-indexed fallback
      if [[ -z "$worktree_path" ]]; then
        for idx in {1..${#options[@]}}; do
          if [[ "${options[$idx]}" == "$choice" ]]; then
            worktree_path="${paths[$idx]}"
            task_name="$(basename "$worktree_path")"
            break
          fi
        done
      fi

      if [[ -z "$worktree_path" ]]; then
        _wt_error "Could not resolve selection"
        return 1
      fi
    fi
  else
    # Resolve by number or name
    if [[ "$task_input" =~ ^[0-9]+$ ]]; then
      local worktrees=("${(@f)$(_wt_get_worktrees "$repo_root")}")
      if (( task_input < 1 || task_input > ${#worktrees[@]} )); then
        _wt_error "Invalid task number: $task_input (valid: 1-${#worktrees[@]})"
        return 1
      fi
      task_name="${worktrees[$task_input]}"
    else
      task_name="$task_input"
    fi

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
      _wt_error "No worktree found with name: $task_name"
      return 1
    fi
  fi

  # Get branch name before removing
  local branch_name
  branch_name=$(git -C "$repo_root" worktree list --porcelain | awk -v path="$worktree_path" '
    $1 == "worktree" && $2 == path { capture = 1 }
    capture && $1 == "branch" { sub("refs/heads/", "", $2); print $2; exit }
  ')

  # Confirmation
  _wt_header "Delete worktree"
  echo ""
  _wt_dim "  name:   $(basename "$worktree_path")"
  [[ -n "$branch_name" ]] && _wt_dim "  branch: $branch_name"
  _wt_dim "  path:   $worktree_path"
  echo ""

  if ! gum confirm "Delete this worktree?" --default=false; then
    _wt_info "Cancelled"
    return 0
  fi

  # Run teardown script if it exists
  local teardown_script="$repo_root/.agents/worktree-teardown.sh"
  if [[ -f "$teardown_script" ]]; then
    _wt_info "Running teardown script..."
    local worktree_name
    worktree_name=$(basename "$worktree_path")
    if ! (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$worktree_name" bash "$teardown_script"); then
      _wt_error "Teardown script failed — aborting"
      return 1
    fi
    _wt_ok "Teardown complete"
  fi

  # Move out if we're inside the worktree being removed
  if [[ "$current_dir" == "$worktree_path"* ]]; then
    cd ..
  fi

  if gum spin --title "Removing worktree..." -- \
    git -C "$repo_root" worktree remove "$worktree_path" --force; then
    _wt_ok "Worktree removed"

    [[ -d "$worktree_path" ]] && rm -rf "$worktree_path"

    if [[ -n "$branch_name" ]]; then
      if git -C "$repo_root" branch -D "$branch_name" >/dev/null 2>&1; then
        _wt_ok "Branch $branch_name deleted"
      else
        _wt_warn "Failed to delete branch $branch_name"
      fi
    fi
  else
    _wt_error "Failed to remove worktree"
    return 1
  fi
}

# ─── helper: get worktree names ──────────────────────────────────────────────

_wt_get_worktrees() {
  local repo_root="$1"
  git -C "$repo_root" worktree list --porcelain | awk '
    /^worktree / {
      path = substr($0, 10)
      if (NR > 1 || path !~ /\.git$/) {
        n = split(path, parts, "/")
        if (path ~ /\/worktrees\//) {
          print parts[n]
        }
      }
    }
  '
}
