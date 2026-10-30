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

# Key bindings
bindkey -v

# Environment
# secret()/load_secrets helpers used by ~/.env (local, never committed)
[ -f ~/.config/zsh/secrets.zsh ] && source ~/.config/zsh/secrets.zsh
[ -f ~/.env ] && source ~/.env

# Node — put the newest nvm-installed version on PATH so node/npm/npx and
# global packages (pi, etc.) are real files on PATH. Programs that spawn npm
# directly can't see shell functions, so lazy shims aren't enough.
export NVM_DIR="$HOME/.nvm"
_node_bin=("$NVM_DIR"/versions/node/*(NnOn[1]))
(( ${#_node_bin} )) && path=("$_node_bin[1]/bin" $path)
unset _node_bin

# nvm itself is slow to load, so load it on first use.
# Homebrew's nvm lives in /opt/homebrew/opt/nvm; the curl installer uses ~/.nvm.
nvm() {
  unset -f nvm
  local dir
  for dir in "$NVM_DIR" /opt/homebrew/opt/nvm; do
    if [ -s "$dir/nvm.sh" ]; then
      source "$dir/nvm.sh"
      [ -s "$dir/etc/bash_completion.d/nvm" ] && source "$dir/etc/bash_completion.d/nvm"
      [ -s "$dir/bash_completion" ] && source "$dir/bash_completion"
      break
    fi
  done
  nvm "$@"
}

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


