# Function to start Neovim with a named pipe for remote neovim (nvr)

e() {
	local root
	root=$(git rev-parse --show-toplevel 2>/dev/null)

	if [[ -z "$root" ]]; then
		echo "⚠️ Not in a Git repository, using current directory"
		root=$(pwd)
	fi

	# Slugify path: replace slashes with dashes
	local slug
	slug=$(echo "$root" | sed 's|/|-|g' | sed 's|^-||')

	export NVIM_PIPE="/tmp/nvim-${slug}.pipe"

	nvim --listen "$NVIM_PIPE"
}
