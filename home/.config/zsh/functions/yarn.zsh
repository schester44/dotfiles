# Yarn script tab completion
# Completes `yarn <tab>` with scripts from package.json
_yarn_scripts() {
  if [[ -f package.json ]]; then
    local -a scripts
    scripts=(${(f)"$(node -e "Object.keys(require('./package.json').scripts||{}).forEach(s=>console.log(s))")"})
    _describe 'yarn scripts' scripts
  fi
}
compdef _yarn_scripts yarn
