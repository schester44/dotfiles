# dotfiles

My Arch Linux dotfiles — Hyprland, Neovim, WezTerm, and more.

![Neovim](images/nvim-screenshot.png)

## What's included

- **Window Manager** — [Hyprland](https://hyprland.org/) (modular config in `home/.config/hypr/conf/`)
- **Editor** — [Neovim](https://neovim.io/) with lazy.nvim, custom themes, LSP, and more
- **Terminal** — [WezTerm](https://wezfurlong.org/wezterm/)
- **Shell** — Zsh with aliases, zoxide, eza, and git worktree management (`wt`)
- **Bar** — [Waybar](https://github.com/Alexays/Waybar)
- **Launcher** — [Walker](https://github.com/abenz1267/walker)
- **Fonts** — Operator Mono Lig, JetBrains Mono Nerd Font

## Structure

```
~/.dotfiles/
├── install.sh              # Main install script
├── install/                # Install subscripts
├── bin/                    # Custom commands (sc)
├── home/                   # Dotfiles linked to ~
│   ├── .config/
│   │   ├── hypr/           # Hyprland config
│   │   ├── nvim/           # Neovim config
│   │   ├── wezterm/        # WezTerm config
│   │   └── zsh/            # Zsh aliases & functions
│   └── .zshrc
├── platform/               # OS-specific setup
│   └── macos/              # macOS (Aerospace, Homebrew, Raycast, etc.)
├── system/
│   ├── packages/           # pacman.txt, npm.txt
│   └── fonts/              # fonts.zip
├── scripts/                # Utility scripts
└── images/                 # Screenshots
```

## Install

```bash
git clone https://github.com/<user>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer will:
1. Prompt for git `user.name` and `user.email`
2. Symlink dotfiles to `~`
3. Install packages and services
4. Install fonts
5. Configure services

## Key packages

| Category | Packages |
|----------|----------|
| Desktop | hyprland, waybar, xdg-desktop-portal-hyprland |
| Apps | firefox, neovim, wezterm |
| Dev | git, github-cli, lazygit, nodejs, npm, base-devel |
| CLI | ripgrep, fzf, eza, zoxide |
| Fonts | ttf-jetbrains-mono, ttf-jetbrains-mono-nerd, Operator Mono Lig |
| Other | vaultwarden, zsh, wl-clipboard, cliphist |

## Custom commands

All commands are accessed through the `sc` dispatcher. See [docs/sc.md](docs/sc.md).

```bash
sc theme grapelean  # Switch color palette, regenerate all themed configs
sc pkg install      # fzf TUI for picking packages to install
sc pkg add <pkg>    # Install packages if missing
sc pkg missing      # Check if packages are installed
sc show done        # Done spinner
```

## Theming

A template-based system that generates app configs (Walker, Waybar, etc.) from a single color palette. See [docs/theming.md](docs/theming.md).

```bash
sc theme              # list palettes with swatches
sc theme cobalt44     # switch — all configs regenerate
```

## Git worktree management

```bash
wt new <name>       # Create a new worktree
wt list             # List worktrees
wt go <name|num>    # Switch to a worktree
wt delete [name]    # Remove a worktree
wt setup            # Run setup script
```
