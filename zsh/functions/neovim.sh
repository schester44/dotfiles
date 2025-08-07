# Neovim with a named pipe for remote neovim (nvr)
e() {
	local root
	root=$(git rev-parse --show-toplevel 2>/dev/null)

	if [[ -z "$root" ]]; then
		echo "⚠️ Not in a Git repository, using current directory"
		root=$(pwd)
	fi

	local slug
	slug=$(echo "$root" | sed 's|/|-|g' | sed 's|^-||')

	local id
	id=$(uuidgen | cut -c1-5)

	export NVIM_PIPE="/tmp/nvim-${slug}-${id}.pipe"

	nvim --listen "$NVIM_PIPE"
}
