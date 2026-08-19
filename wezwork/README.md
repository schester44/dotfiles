# wezwork

A live terminal dashboard for Pi sessions running across WezTerm panes.

`wezwork` is a single Go binary containing the Pi extension it needs. The extension publishes private, versioned session heartbeats; the app joins those records with `wezterm cli list` to show both Pi and WezTerm metadata.

## Install

Requirements: Go 1.24+, WezTerm, and Pi on macOS or Linux.

```sh
make install
```

This installs the binary to `$(go env GOPATH)/bin/wezwork` and the bundled extension to:

```text
${PI_CODING_AGENT_DIR:-~/.pi/agent}/extensions/wezwork.ts
```

Run `/reload` once in Pi panes that were already open. New Pi sessions load the extension automatically. The first `wezwork` or `wezwork list` run also installs a missing extension.

## Usage

```sh
wezwork                 # interactive live dashboard
wezwork list            # plain-text snapshot
wezwork list --json     # machine-readable snapshot
wezwork install         # install/update the Pi extension
wezwork uninstall       # remove the managed Pi extension
wezwork doctor          # diagnose the integration
```

TUI keys:

- `j`/`k` or arrows: select a session
- `Enter`: focus the selected WezTerm pane while keeping wezwork open
- `r`: refresh
- `q`, Escape, or Ctrl-C: quit

## Data shown

Pi metadata includes session ID/file/name, cwd, state, model/provider, thinking level, entry count, context usage, and process ID.

WezTerm metadata includes workspace, window/tab/pane IDs, pane/tab/window titles, cwd, dimensions, DPI, active/zoom state, cursor state, and tty where available.

Git metadata includes repository root, branch, changed/untracked files, additions/deletions, and upstream ahead/behind counts. The layout adapts automatically: narrow panes use compact three-line agent cards suitable for a sidebar, while wider panes show a table and full detail panel.

## How discovery works

The Pi extension publishes metadata in two places:

1. A WezTerm `SetUserVar` OSC value named `wezwork_pi`, for future WezTerm Lua integrations.
2. An atomic heartbeat record in `${WEZWORK_STATE_DIR:-${XDG_STATE_HOME:-~/.local/state}/wezwork}/live/<pane-id>-<pid>.json`.

The filesystem registry is necessary because `wezterm cli list --format json` does not expose pane user variables. Records use private permissions, contain no prompts or message bodies, and are ignored when stale, when their process is gone, or when their pane no longer exists.

## Development

```sh
make test
make build
./wezwork doctor
```
