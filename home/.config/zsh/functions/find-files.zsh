cdd() {
  local dir
  dir="$(fd -t d . "${1:-.}" | fzf)" || return
  cd "$dir"
}

ff() {
  local file
  file="$(fd -t f . "${1:-.}" | fzf)" || return
  nvim "$file"
}
