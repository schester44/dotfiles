---
name: worktree
description: "Manage git worktrees using the `wt` shell function. Use when the user asks to create, list, switch to, or delete worktrees, or when working on isolated branches."
---

# Git Worktree Skill (`wt`)

The `wt` command is a zsh function (defined in `~/.config/zsh/functions/wt.zsh`) that wraps `git worktree` with ergonomic defaults, WezTerm integration, and per-repo setup/teardown scripts.

## Important: `wt` is a shell function, not available via `bash`

Since `wt` is a zsh function, you **cannot** call it directly from the `bash` tool. Instead, use the underlying `git worktree` commands directly when operating programmatically:

```bash
# Instead of: wt new my-feature
git worktree add -b my-feature ~/worktrees/<repo>/my-feature origin/main

# Instead of: wt list
git worktree list

# Instead of: wt delete my-feature
git worktree remove ~/worktrees/<repo>/my-feature --force
git branch -D my-feature
```

## Worktree Layout

Worktrees are created under `~/worktrees/<repo-name>/`:

```
~/worktrees/
  risk-management/
    my-feature/
    bugfix-123/
  surefin/
    billing-update/
```

The main repo checkout stays in its original location (e.g., `~/work/risk-management`). Worktrees are separate working directories that share the same `.git` object store.

## Commands Reference

| Command | Alias | Description |
|---------|-------|-------------|
| `wt new <name> [base]` | `n` | Create worktree with a new branch |
| `wt checkout <branch>` | `co` | Create worktree from an existing branch |
| `wt list` | `ls`, `l` | List all worktrees |
| `wt go <num\|name>` | `g` | Jump to a worktree (interactive if no arg) |
| `wt delete [num\|name]` | `d`, `rm` | Delete a worktree (interactive if no arg) |
| `wt setup` | `s` | Re-run setup script in current worktree |

## Creating Worktrees

### New branch (most common)

```bash
# Branch off main (default)
wt new my-feature

# Branch off a specific base
wt new my-feature develop

# Branch off the current branch
wt new my-feature .
```

Programmatic equivalent:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
WORKTREE_PATH="$HOME/worktrees/$REPO_NAME/my-feature"

git fetch origin main
git worktree add -b my-feature "$WORKTREE_PATH" origin/main
```

### Existing branch

```bash
wt checkout steve/existing-branch
```

Programmatic equivalent:

```bash
git fetch origin "+refs/heads/steve/existing-branch:refs/remotes/origin/steve/existing-branch"
git worktree add "$WORKTREE_PATH" steve/existing-branch
```

## Listing Worktrees

```bash
wt list
```

Programmatic equivalent:

```bash
git worktree list
```

Only worktrees under `~/worktrees/` are shown by `wt list` (the main checkout is excluded).

## Deleting Worktrees

```bash
# Delete by name
wt delete my-feature

# Delete current worktree (if inside one)
wt delete

# Interactive picker
wt delete
```

Programmatic equivalent:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
WORKTREE_PATH="$HOME/worktrees/$REPO_NAME/my-feature"

# Run teardown if it exists
TEARDOWN="$REPO_ROOT/.agents/worktree-teardown.sh"
if [ -f "$TEARDOWN" ]; then
  (cd "$WORKTREE_PATH" && REPO_ROOT="$REPO_ROOT" WORKTREE_PATH="$WORKTREE_PATH" WORKTREE_NAME="my-feature" bash "$TEARDOWN")
fi

git worktree remove "$WORKTREE_PATH" --force
git branch -D my-feature  # also delete the branch
```

**Note:** `wt delete` also deletes the local branch after removing the worktree. It runs teardown scripts and prompts for confirmation (which the user handles interactively).

## Setup & Teardown Scripts

Repos can define lifecycle scripts in `.agents/`:

- **`.agents/worktree-setup.sh`** — Runs after worktree creation (e.g., `yarn install`, DB migration). Called with env vars: `REPO_ROOT`, `WORKTREE_PATH`, `WORKTREE_NAME`.
- **`.agents/worktree-teardown.sh`** — Runs before worktree deletion (e.g., cleanup). Same env vars.

To re-run setup manually:

```bash
wt setup
```

Programmatic equivalent:

```bash
REPO_ROOT=$(git -C . rev-parse --git-common-dir | xargs dirname)
SETUP="$REPO_ROOT/.agents/worktree-setup.sh"
if [ -f "$SETUP" ]; then
  REPO_ROOT="$REPO_ROOT" WORKTREE_PATH="$(pwd)" WORKTREE_NAME="$(basename $(pwd))" bash "$SETUP"
fi
```

## WezTerm Integration

When run interactively, `wt new` and `wt checkout` automatically:

1. Open the worktree in a new WezTerm tab (or reuse the current tab if it has only one pane)
2. Set the tab title to the worktree name
3. Open the editor (`e`) in the left pane
4. Start `pi` in a right split pane

This only applies to interactive use — when the agent creates worktrees programmatically, use `git worktree` commands directly without the WezTerm integration.

## Common Workflows

### Create a worktree for a feature branch, do work, and clean up

```bash
# Determine paths
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
BRANCH_NAME="steve/my-feature"
WORKTREE_PATH="$HOME/worktrees/$REPO_NAME/my-feature"

# Create
git fetch origin main
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" origin/main

# Run setup if available
SETUP="$REPO_ROOT/.agents/worktree-setup.sh"
[ -f "$SETUP" ] && (cd "$WORKTREE_PATH" && REPO_ROOT="$REPO_ROOT" WORKTREE_PATH="$WORKTREE_PATH" WORKTREE_NAME="my-feature" bash "$SETUP")

# Do work in the worktree...
cd "$WORKTREE_PATH"

# Clean up when done
cd "$REPO_ROOT"
git worktree remove "$WORKTREE_PATH" --force
git branch -D "$BRANCH_NAME"
```
