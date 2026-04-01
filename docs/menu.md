# Space Cake Menu

The Space Cake Menu is a searchable, hierarchical launcher built on [Walker](https://github.com/abenz1267/walker) and [Elephant](https://github.com/abenz1267/elephant). It provides quick access to toggles, config shortcuts, system actions, and anything else you want a keybind away.

## Opening the menu

| Keybind | Action |
|---------|--------|
| `ALT_R + M` | Open the Space Cake Menu |

Walker's search bar filters across all entries. Select a category to drill into its submenu, or just start typing to find what you need.

## How it works

The menu is defined as a set of TOML files read by Elephant (Walker's data backend). Walker displays them with built-in fuzzy search, submenu navigation, and action execution.

```
~/.config/elephant/menus/
├── quickmenu.toml            # top-level menu (categories)
├── quickmenu_toggle.toml     # Toggle submenu
├── quickmenu_config.toml     # Config submenu
└── quickmenu_system.toml     # System submenu
```

In this dotfiles repo, these live at:

```
~/.dotfiles/home/.config/elephant/menus/
```

The Hyprland keybind invokes Walker directly:

```
bind = $hyper, M, exec, walker -m menus:quickmenu
```

## Current menu structure

```
Quick Menu
├── Toggle
│   └── Ironbar          # show/hide the status bar
├── Config
│   └── Open Dotfiles    # open ~/.dotfiles in nvim
└── System
    └── Restart          # systemctl reboot
```

## Adding a new entry to an existing submenu

Add an `[[entries]]` block to the relevant TOML file. Each entry needs:

| Field | Required | Description |
|-------|----------|-------------|
| `text` | yes | Display label |
| `icon` | no | Icon name (freedesktop icon theme) |
| `actions` | yes* | Map of action name → shell command |
| `submenu` | yes* | Name of another menu to navigate to |

*An entry needs either `actions` or `submenu`, not both.

### Example: add a "Shutdown" entry to the System submenu

Edit `quickmenu_system.toml`:

```toml
[[entries]]
text = "Shutdown"
icon = "system-shutdown"
actions = { "shutdown" = "systemctl poweroff" }
```

Restart Elephant to pick up changes:

```bash
systemctl --user restart elephant
```

## Adding a new submenu

1. **Create the submenu file** at `~/.dotfiles/home/.config/elephant/menus/quickmenu_<name>.toml`:

```toml
name = "quickmenu_capture"
name_pretty = "Capture"
icon = "camera-photo"

[[entries]]
text = "Screenshot"
icon = "camera-photo"
actions = { "screenshot" = "grim -g \"$(slurp)\" - | wl-copy" }

[[entries]]
text = "Color Picker"
icon = "color-picker"
actions = { "pick" = "hyprpicker -a" }
```

2. **Link it from the top-level menu** in `quickmenu.toml`:

```toml
[[entries]]
text = "Capture"
icon = "camera-photo"
submenu = "quickmenu_capture"
```

3. **Restart Elephant**:

```bash
systemctl --user restart elephant
```

## Adding a toggle command

Toggle scripts live at `~/.dotfiles/bin/sc-commands/toggle/` and follow a simple pattern:

```bash
#!/bin/bash

if pgrep -x <process> &>/dev/null; then
  pkill -x <process>
else
  hyprctl dispatch exec "systemd-run --user --no-block <process>"
fi
```

The `hyprctl dispatch exec` + `systemd-run` pattern ensures the process is fully detached and survives the menu closing.

Then reference it in `quickmenu_toggle.toml`:

```toml
[[entries]]
text = "My Thing"
icon = "applications-other"
actions = { "toggle" = "$HOME/.dotfiles/bin/sc-commands/toggle/mything" }
```

## Entry action types

Actions are shell commands. Some patterns:

```toml
# Simple command
actions = { "run" = "firefox" }

# Command with arguments
actions = { "open" = "wezterm start --cwd $HOME/.dotfiles -- nvim" }

# Script
actions = { "toggle" = "$HOME/.dotfiles/bin/sc-commands/toggle/ironbar" }

# Multiple actions (user picks which one)
[entries.actions]
"volume_up" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
"volume_down" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
"mute" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0"
```

## Dynamic menus with Lua

For menus that need to generate entries at runtime, use a Lua script instead of TOML. Place it in the same `menus/` directory:

```lua
Name = "quickmenu_dynamic"
NamePretty = "Dynamic Menu"
Icon = "applications-other"
Cache = false  -- regenerate entries on every open

function GetEntries()
    local entries = {}
    -- build entries dynamically
    table.insert(entries, {
        Text = "example",
        Actions = { run = "notify-send hello" },
    })
    return entries
end
```

See the [Elephant menus documentation](https://github.com/abenz1267/elephant/blob/master/internal/providers/menus/README.md) for the full Lua API.

## Dependencies

| Package | Source | Purpose |
|---------|--------|---------|
| `walker` | AUR | Menu UI |
| `elephant-bin` | AUR | Data backend |
| `elephant-menus-bin` | AUR | Menus provider plugin |

Install the menus provider if not already installed:

```bash
yay -S elephant-menus-bin
systemctl --user restart elephant
```

## Troubleshooting

**"No results" when opening menu**
- Ensure `elephant-menus-bin` is installed
- Restart Elephant: `systemctl --user restart elephant`
- Check logs: `journalctl --user -u elephant -f`

**Menu entries not updating after edits**
- Elephant caches menus on startup. Restart it: `systemctl --user restart elephant`

**Toggle brings up process but it dies immediately**
- Use `hyprctl dispatch exec "systemd-run --user --no-block <cmd>"` to fully detach the process from the menu's process tree

**Check available menus**
```bash
elephant listproviders
```
