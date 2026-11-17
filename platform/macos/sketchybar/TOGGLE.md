# SketchyBar Toggle fork

- Fork: https://github.com/schester44/sketchybar-toggle
- Upstream PR: https://github.com/malpern/sketchybar-toggle/pull/9
- Local development checkout: `~/work/sketchybar-toggle`
- Remotes: `origin` is the fork; `upstream` is `malpern/sketchybar-toggle`.
- Fork `main` includes the patch; `feat/hide-delay` is the upstream PR branch.

`init.lua` explicitly launches `~/.local/bin/sketchybar-toggle` with
`--hide-delay 100`. The cursor must stay within the top 4 pixels for 100ms before
SketchyBar hides. Leaving that zone cancels the pending hide. `--debounce 1`
independently controls restoration after leaving the 35px menu-bar area.

It also passes `--hide-event` / `--show-event`, so the toggle only triggers
SketchyBar events and `utils/bar_visibility.lua` does the hiding: the left and
right items slide up, the notch chips shrink into the notch, then the bar is
hidden. Showing reverses it. Register anything else that should slide with
`visibility.slide(name)`.

This does not detect actual native menu bar visibility. Tune the delay if the
bars overlap on your system.

## Install or reinstall

```sh
bash ~/.dotfiles/platform/macos/sketchybar/install-toggle.sh
sketchybar --reload
```

The installer clones the fork into a temporary directory, checks out its `main`,
runs tests, builds a release binary, and installs it in `~/.local/bin`.
It is also called by `install-mac.sh`. Homebrew's original binary is left intact
and is not used by this config.

## Maintain the fork

Do development on `feat/hide-delay` while the PR is open; commits pushed there
update the PR. Run `swift test` and `swift build -c release` before pushing.
Fast-forward the fork's `main` to tested changes when appropriate, then
reinstall; the installer builds whatever `main` is at that time.

To incorporate upstream updates without dropping the patch:

```sh
cd ~/work/sketchybar-toggle
git fetch upstream
git switch feat/hide-delay
git merge upstream/main
swift test
swift build -c release
git push origin feat/hide-delay
git switch main
git merge --ff-only feat/hide-delay
git push origin main
```

Resolve any merge conflicts before continuing. Once upstream merges the PR,
review the resulting history before synchronizing `main`; a squash merge may
require reconciling duplicate patch history rather than a fast-forward.
