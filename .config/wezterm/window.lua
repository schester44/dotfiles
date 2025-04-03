local M = {}

M.apply = function(config)
	local wezterm = require("wezterm")

	config.window_decorations = "RESIZE"

	config.window_padding = {
		left = 0,
		right = 0,
		top = 4,
		bottom = 0,
	}

	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = false
	config.tab_bar_at_bottom = true

	config.status_update_interval = 1000

	wezterm.on("update-status", function(window)
		local active_key_table = window:active_key_table()

		window:set_right_status(wezterm.format({
			{ Text = active_key_table and wezterm.nerdfonts.md_airplane .. " " .. active_key_table .. " " or "" },
			{ Text = wezterm.nerdfonts.fa_terminal .. " " .. window:active_workspace() .. " " },
		}))
	end)

	return config
end

return M
