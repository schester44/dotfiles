# sc — command dispatcher

`sc` is the central command dispatcher for dotfiles operations. It routes to standalone commands or module/action pairs under `~/.dotfiles/bin/sc-commands/`.

## Usage

```bash
sc <command> [args...]          # standalone command
sc <module> <action> [args...]  # module action
```

Running `sc` with no arguments lists all available commands.

## Commands

### `sc theme`

Switch the active color palette and regenerate themed configs. See [theming.md](theming.md).

```bash
sc theme              # list available palettes with color swatches
sc theme grapelean    # switch to grapelean palette
sc theme cobalt44     # switch to cobalt44 palette
```

### `sc pkg`

Package management helpers.

```bash
sc pkg install        # fzf TUI for picking packages to install
sc pkg add <pkg>      # install a package if not already installed
sc pkg missing        # check which packages from package lists aren't installed
sc pkg remove <pkg>   # remove a package
sc pkg rm <pkg>       # alias for remove
```

### `sc toggle`

Toggle services on/off.

```bash
sc toggle ironbar     # show/hide the status bar
```

### `sc launch`

Launch helpers.

```bash
sc launch webapp <url>  # open a URL in Firefox, focusing it if already running
```

### `sc terminal`

Terminal helpers.

```bash
sc terminal cwd       # print the CWD of the active terminal's shell
```

### `sc show`

Display helpers.

```bash
sc show done          # show a "Done!" spinner, wait for keypress
```

### `sc menu`

The Space Cake Menu — a searchable hierarchical launcher. See [menu.md](menu.md).

Note: the menu is typically opened via keybind (`ALT_R + M`) which calls Walker directly, but `sc menu` also works as a standalone fallback.

## Adding commands

### Standalone command

Create an executable file at `~/.dotfiles/bin/sc-commands/<name>`:

```bash
#!/usr/bin/env bash
echo "hello from sc mycommand"
```

```bash
chmod +x ~/.dotfiles/bin/sc-commands/mycommand
sc mycommand
```

### Module with actions

Create a directory with executable files for each action:

```
~/.dotfiles/bin/sc-commands/mymodule/
├── start
├── stop
└── status
```

```bash
sc mymodule start
sc mymodule status
```

## Structure

```
~/.dotfiles/bin/
├── sc                      # dispatcher
└── sc-commands/
    ├── menu                # sc menu (fallback)
    ├── theme               # sc theme
    ├── show/
    │   └── done            # sc show done
    ├── pkg/
    │   ├── install         # sc pkg install
    │   ├── add             # sc pkg add
    │   ├── missing         # sc pkg missing
    │   ├── remove          # sc pkg remove
    │   └── rm              # sc pkg rm
    ├── toggle/
    │   └── ironbar         # sc toggle ironbar
    ├── launch/
    │   └── webapp          # sc launch webapp <url>
    └── terminal/
        └── cwd             # sc terminal cwd
```
