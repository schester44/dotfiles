# Set TERM appropriately — let tmux set its own
if [[ -z "$TMUX" ]]; then
  export TERM="xterm-256color"
fi
# Resolve DOTFILES from this symlinked .zshrc back to the repo root
# .zshrc lives at <repo>/home/.zshrc, so go up two levels
_zshrc="${(%):-%x}"
if [[ -L "$_zshrc" ]]; then
  # macOS readlink doesn't support -f; use a POSIX-friendly resolution
  _zshrc="$(cd "$(dirname "$_zshrc")" && cd "$(dirname "$(readlink "$_zshrc")")" && pwd)/$(basename "$(readlink "$HOME/.zshrc")")"
fi
export DOTFILES="$(cd "$(dirname "$(dirname "$_zshrc")")" && pwd)"
unset _zshrc
export VISUAL="nvim"
export EDITOR="nvim"

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_dups hist_ignore_space

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# fzf-tab — must be after compinit, before other plugins
[ -f /usr/share/zsh/plugins/fzf-tab/fzf-tab.zsh ] && \
  source /usr/share/zsh/plugins/fzf-tab/fzf-tab.zsh
[ -f /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh ] && \
  source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

# Key bindings
bindkey -v

# Environment
[ -f ~/.env ] && source ~/.env

# JavaScript tooling — load NVM on first use
# Keep this list centralized so every shim is removed after NVM initializes.
typeset -ga __lazyLoadLabels=(
  bun
  bunx
  corepack
  node
  npm
  npx
  nvm
  pnpm
  pnpx
  turbo
  typescript-language-server
  yarn
)

__load-nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
}

__work() {
  local label
  for label in "${__lazyLoadLabels[@]}"; do
    unset -f "$label"
  done
  unset __lazyLoadLabels

  __load-nvm
  unset -f __load-nvm __work
}

for label in "${__lazyLoadLabels[@]}"; do
  eval "$label() { __work; $label \"\$@\"; }"
done
unset label

# Aliases
[ -f ~/.config/zsh/aliases.zsh ] && source ~/.config/zsh/aliases.zsh

# Auto-source all function files
for f in ~/.config/zsh/functions/*.zsh; do
  [ -f "$f" ] && source "$f"
done

# Plugins — Arch (pacman) paths
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Plugins — macOS (Homebrew) paths
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh

# Prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Path
export PATH="$DOTFILES/bin:$HOME/.local/bin:$PATH"


# Local overrides (not committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local


# Added by git-ai installer on Wed Jul 29 20:01:12 EDT 2026
export PATH="/Users/steve/.git-ai/bin:$PATH"
