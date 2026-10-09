# Secrets-from-Bitwarden helper (rbw). No secrets live in dotfiles:
# a local, uncommitted ~/.env declares what to load:
#
#   secret VAULT_ITEM [ENV_VAR]   # ENV_VAR defaults to the item name
#   ...
#   load_secrets                  # fetches everything in parallel
#
# Requires: rbw (https://github.com/doy/rbw) logged in to your server.

_SECRETS=()

secret() { _SECRETS+=("$1:${2:-$1}") }

load_secrets() {
  eval "$(
    for pair in "${_SECRETS[@]}"; do
      ( v=$(rbw get "${pair%%:*}" 2>/dev/null) && echo "export ${pair##*:}=\"$v\"" ) &
    done
    wait
  )"
  unset -f secret load_secrets
  unset _SECRETS
}
