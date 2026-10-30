# macOS

macOS-specific system preferences and defaults.

## What it configures

- **Accessories** — screenshots saved to `~/Pictures/Screenshots`
- **Finder** — show hidden files and extensions, list view, path bar and status bar, folders first, no `.DS_Store` on network/USB drives
- **Dock** — auto-hide with no delay, icon size 45, no pinned or recent apps, minimize into app icon, no hot corners
- **Windows** — hide menu bar, turn off macOS tiling, Stage Manager, Mission Control gestures and shortcuts, and click-desktop-to-show-desktop; don't reorder Spaces
- **Wallpaper** — sets `wallpaper.jpg` from the repo root on every display
- **Inputs** — fast key repeat, press-and-hold off (held keys repeat), tap to click

## Setup

```bash
./platform/macos/setup.sh
```
