local wezzy = require("wezzy")

local config = wezzy.setup({
	window = {
		padding = { left = 10, right = 10, top = 10, bottom = 10 },
		opacity = 0.8,
	},

	wezterm = function(config)
		require("theme").apply(config)
		config.enable_kitty_keyboard = true
		config.audible_bell = "SystemBeep"
	end,

	plugins = { "https://github.com/smart-splits-nvim/backend-wezterm" },

	keys = {
		{ "cmd+shift+a", wezzy.action.FindAgent },
	},

	workspaces = {
		{ name = "neverwait", cwd = "~/work/neverwait" },
	},
})

-- Cmd-d: Diffview in a new tab, working tree (incl. uncommitted) vs the merge
-- base with the upstream branch; falls back to origin's default branch when
-- there's no upstream, and to plain uncommitted changes outside of either.
wezzy.bind("cmd+d", function(window, pane)
	local cwd = pane:get_current_working_dir()
	window:perform_action(
		wezzy.action.SpawnCommandInNewTab({
			cwd = cwd and cwd.file_path or nil,
			args = {
				os.getenv("SHELL") or "/bin/zsh",
				"-lc",
				[[base=$(git merge-base HEAD @{upstream} 2>/dev/null || git merge-base HEAD origin/HEAD 2>/dev/null); exec nvim -c "DiffviewOpen $base"]],
			},
		}),
		pane
	)
end)

return config
