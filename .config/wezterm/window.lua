local M = {}

local theme = require("theme").theme

M.apply = function(config)
	local wezterm = require("wezterm")

	config.window_decorations = "RESIZE"

	config.window_padding = {
		left = 0,
		right = 0,
		top = 4,
		bottom = 0,
	}

	config.tab_max_width = 64
	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = false
	config.tab_bar_at_bottom = true
	config.show_new_tab_button_in_tab_bar = false

	config.status_update_interval = 1000

	local active_key_maps = {
		resize_pane = "Resize Pane",
	}

	wezterm.on("format-tab-title", function(tab)
		local is_zoomed = tab.active_pane.is_zoomed

		local title = tab.tab_title and tab.tab_title ~= "" and tab.tab_title or "Tab" .. tab.tab_index + 1

		local elements = {
			{ Background = { Color = is_zoomed and theme.alert or theme.background } },
		}

		if is_zoomed then
			table.insert(elements, {
				Background = { Color = theme.background },
			})

			table.insert(elements, {
				Foreground = { Color = theme.alert },
			})
		end

		table.insert(elements, { Text = " " .. wezterm.nerdfonts["md_numeric_" .. tab.tab_index + 1 .. "_box"] .. " " })

		table.insert(elements, { Text = title .. " " })

		return elements
	end)

	wezterm.on("update-status", function(window)
		local active_key_table = window:active_key_table()
		local key_map_name = active_key_maps[active_key_table]

		local active_key_title = (key_map_name and key_map_name or active_key_table)

		window:set_left_status(wezterm.format({
			{
				Foreground = {
					Color = theme.alert,
				},
			},
			{
				Text = active_key_table and " " .. wezterm.nerdfonts.cod_layout .. " " .. active_key_title or "",
			},
			{ Foreground = { Color = theme.foreground } },
			{
				Text = " " .. wezterm.nerdfonts.fa_terminal .. " " .. window:active_workspace() .. " ",
			},
		}))
	end)

	return config
end

return M
