---
name: wezterm
description: "Remote control WezTerm panes for interactive CLIs (python, gdb, etc.) by sending text and capturing pane output."
license: Vibecoded
---

# WezTerm Skill

Use WezTerm's CLI to programmatically control terminal panes for interactive work. Works on Linux and macOS with WezTerm's built-in mux server.

## Quickstart

```bash
# Spawn a Python REPL in a new window, capture the pane ID
PANE_ID=$(wezterm cli spawn --new-window -- bash -c 'PYTHON_BASIC_REPL=1 exec python3 -q')

# Send code to the pane
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'print("hello world")\n'

# Capture output (last 200 lines)
wezterm cli get-text --pane-id "$PANE_ID" --start-line -200

# List all panes
wezterm cli list --format json

# Kill the pane when done
wezterm cli kill-pane --pane-id "$PANE_ID"
```

After spawning a pane, ALWAYS tell the user how to monitor it:

```
To monitor this pane yourself, run:
  wezterm cli get-text --pane-id $PANE_ID --start-line -200

To focus the pane and interact directly:
  wezterm cli activate-pane --pane-id $PANE_ID

Or list all panes:
  wezterm cli list
```

This must ALWAYS be printed right after a pane was started and once again at the end of the tool loop.

## Pane Management

### Spawning Panes

```bash
# New tab in a specific window (preferred - stays in user's workspace)
PANE_ID=$(wezterm cli spawn --window-id 1 -- python3 -q)

# New window (NOTE: creates in "default" workspace, user may not see it!)
PANE_ID=$(wezterm cli spawn --new-window -- python3 -q)

# New tab in current window (only works if WEZTERM_PANE env var is set)
PANE_ID=$(wezterm cli spawn -- bash)

# With working directory
PANE_ID=$(wezterm cli spawn --window-id 1 --cwd /path/to/dir -- bash)

# Split current pane
PANE_ID=$(wezterm cli split-pane -- bash)
```

**Important:** Using `--new-window` creates a window in the "default" workspace, which the user may not be viewing. Prefer `--window-id` to spawn a tab in their current window. Get the window ID from `wezterm cli list --format json`.

### Listing Panes

```bash
# Table format
wezterm cli list

# JSON format (better for scripting)
wezterm cli list --format json

# Find panes with helper script
./scripts/list-panes.sh                    # all panes
./scripts/list-panes.sh -q python          # filter by title/command
```

### Targeting Panes

WezTerm uses numeric pane IDs. Store the ID when spawning:

```bash
PANE_ID=$(wezterm cli spawn --new-window -- python3)
# Use $PANE_ID for all subsequent commands
```

## Sending Input

### Text Input

```bash
# Send text with newline (--no-paste avoids bracketed paste mode issues)
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'print("hello")\n'

# Send multiline code
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'def greet(name):
    return f"Hello, {name}"

greet("world")
'

# From stdin
echo 'print("from stdin")' | wezterm cli send-text --pane-id "$PANE_ID" --no-paste
```

### Control Characters

WezTerm's send-text can send raw control characters:

```bash
# Ctrl-C (interrupt)
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'\x03'

# Ctrl-D (EOF)
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'\x04'

# Ctrl-Z (suspend)
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'\x1a'

# Escape
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'\x1b'

# Ctrl-L (clear screen)
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'\x0c'
```

## Activating / Focusing a Pane

To let the user interact directly with a pane (like `tmux attach`):

```bash
# Focus the pane - brings window to front and selects the pane
wezterm cli activate-pane --pane-id "$PANE_ID"
```

This is useful when you want to hand control back to the user, or let them type alongside the agent.

## Capturing Output

```bash
# Get visible screen content
wezterm cli get-text --pane-id "$PANE_ID"

# Get last N lines of scrollback
wezterm cli get-text --pane-id "$PANE_ID" --start-line -200

# Get specific range (0 = first line of visible screen, negative = scrollback)
wezterm cli get-text --pane-id "$PANE_ID" --start-line -100 --end-line -1

# Include ANSI escape codes (colors, styles)
wezterm cli get-text --pane-id "$PANE_ID" --escapes
```

## Synchronizing / Waiting for Prompts

Use timed polling to wait for expected output before proceeding:

```bash
# Wait for Python prompt
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '^>>>' --timeout 15

# Wait for specific output
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern 'Program exited' --timeout 30

# Fixed string match (not regex)
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '(gdb)' --fixed --timeout 10
```

## Spawning Processes

Special rules for interactive tools:

- **Python**: Always use `PYTHON_BASIC_REPL=1` to disable the fancy REPL that interferes with send-text
- **Debuggers**: Use lldb by default when asked to debug

### Python REPL

```bash
PANE_ID=$(wezterm cli spawn --new-window -- bash -c 'PYTHON_BASIC_REPL=1 exec python3 -q')
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '^>>>'
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'x = 42\n'
```

### LLDB

```bash
PANE_ID=$(wezterm cli spawn --new-window -- lldb ./myprogram)
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '^\(lldb\)' --timeout 30
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'breakpoint set -n main\n'
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'run\n'
```

### GDB

```bash
PANE_ID=$(wezterm cli spawn --new-window -- gdb --quiet ./a.out)
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '^\(gdb\)'
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'set pagination off\n'
```

## Interactive Tool Recipes

### General Pattern

1. Spawn the tool, capture pane ID
2. Wait for the prompt
3. Send commands with `--no-paste` and explicit `\n`
4. Capture output to check results
5. Repeat 3-4 as needed
6. Clean up with kill-pane

### Node.js REPL

```bash
PANE_ID=$(wezterm cli spawn --new-window -- node)
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '^>'
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'const x = [1,2,3].map(n => n*2)\n'
```

### Interactive Shell

```bash
PANE_ID=$(wezterm cli spawn --new-window -- bash)
./scripts/wait-for-text.sh --pane-id "$PANE_ID" --pattern '\$'
wezterm cli send-text --pane-id "$PANE_ID" --no-paste $'cd /tmp && ls -la\n'
```

## Cleanup

```bash
# Kill a specific pane
wezterm cli kill-pane --pane-id "$PANE_ID"

# Kill multiple panes (get IDs from list)
wezterm cli list --format json | jq -r '.[].pane_id' | xargs -I{} wezterm cli kill-pane --pane-id {}
```

## Helper Scripts

### wait-for-text.sh

Polls a pane for a regex (or fixed string) with timeout:

```bash
./scripts/wait-for-text.sh --pane-id ID --pattern 'regex' [options]
```

Options:
- `--pane-id` / `-p`: WezTerm pane ID (required)
- `--pattern` / `-P`: Regex to match (required)
- `--fixed` / `-F`: Treat pattern as fixed string
- `--timeout` / `-T`: Seconds to wait (default: 15)
- `--interval` / `-i`: Poll interval in seconds (default: 0.5)
- `--lines` / `-l`: History lines to search (default: 1000)

Exits 0 on match, 1 on timeout. On failure, prints last captured text to stderr.

### list-panes.sh

List panes with optional filtering:

```bash
./scripts/list-panes.sh              # all panes
./scripts/list-panes.sh -q python    # filter by substring
./scripts/list-panes.sh --json       # JSON output
```

## Differences from tmux

| Aspect | tmux | WezTerm |
|--------|------|---------|
| Targeting | `session:window.pane` strings | Numeric pane IDs |
| Sessions | Named sessions | Windows/workspaces (no direct equivalent) |
| Isolation | Socket files (`-S path`) | `--class` flag or separate mux servers |
| Send keys | `send-keys C-c` | `send-text $'\x03'` |
| Capture | `capture-pane -p -J` | `get-text --start-line -N` |

## Troubleshooting

### "No mux server running"

WezTerm CLI requires a running WezTerm GUI or mux server. Start WezTerm GUI first, or run:

```bash
wezterm start --daemonize
```

### Bracketed paste issues

Always use `--no-paste` when sending commands to REPLs to avoid bracketed paste mode interfering with input.

### Pane ID not found

Pane IDs are invalidated when panes close. Always check `wezterm cli list` if you get errors about missing panes.
