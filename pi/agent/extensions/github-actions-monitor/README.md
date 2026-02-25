# GitHub Actions Monitor Extension

A Pi extension that provides a `/pr` slash command and automatic GitHub Actions monitoring with CI failure auto-fix capabilities.

## Features

### `/pr` Slash Command

Create pull requests directly from Pi with a single command:

```
/pr                      # Commit changes and create PR
/pr fix auth bug         # With additional context for the PR description
/pr --new                # Force create a new branch from main/master
```

**What it does:**
1. Checks for uncommitted changes
2. Creates a feature branch if on main/master (or with `--new`)
3. Stages and commits all changes
4. Pushes to origin
5. Creates a PR via `gh pr create`

### GitHub Actions Monitoring

After creating a PR, the extension automatically:

- **Polls workflows** every 15 seconds for the current branch
- **Shows status widget** with real-time CI progress
- **Detects early failures** - notifies immediately when jobs fail, don't wait for workflow completion
- **Auto-triggers fixes** - sends CI failure details to the model to investigate and fix
- **Prevents infinite loops** - stops auto-fix after 5 attempts

#### Status Widget

The widget shows in the Pi UI:
- `◆` Running workflow with job progress (2/5)
- `✓` Successful workflow (green)
- `✗` Failed workflow with failed job names (red)
- `◇` Queued workflow

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- Git repository with GitHub remote

## Configuration

No configuration needed! The extension activates automatically when:
- You're on a non-main/master branch
- A new commit is pushed (detected on turn end)

Monitoring stops automatically after 2 minutes of no active runs.

## How It Works

1. **Branch detection**: Monitors `turn_end` events for branch/commit changes
2. **Run tracking**: Fetches workflow runs via `gh run list` filtered by branch and HEAD commit
3. **Job polling**: For in-progress runs, fetches job details to detect early failures
4. **Notifications**: Sends messages to trigger model investigation on failures
5. **Widget rendering**: Shows compact status in the Pi UI

## Example Workflow

```
You: /pr fix the login validation bug

Pi: [Creates branch fix/login-validation-bug]
    [Commits changes]
    [Pushes and creates PR]
    
Widget: ◆ CI 0/3 12s

[CI fails]

Widget: ✗ CI (lint)

Pi: [Receives failure notification]
    [Runs: gh run view 12345 --log-failed]
    [Identifies issue and fixes]
    [Commits and pushes fix]
    
Widget: ◆ CI 0/3 5s
...
Widget: ✓ CI
```

## Slash Command Reference

| Command | Description |
|---------|-------------|
| `/pr` | Commit all changes and create PR |
| `/pr <context>` | Create PR with additional context for description |
| `/pr --new` | Stash changes, checkout main, pull, create new branch |
| `/pr --new <context>` | Combine --new with context |
