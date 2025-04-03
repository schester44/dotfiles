local M = {}

local palette = {
	cobalt_bg = "#1C2E41",
	cobalt_bg_dark = "#15232D",
	purple = "#967EFB",
	light_yellow = "#FFEE80",
	light_grey = "#9E9E9E",
}

M.apply = function(config)
	local wezterm = require("wezterm")

	config.color_scheme = "Cobalt2"

	config.colors = {
		background = palette.cobalt_bg,
		cursor_fg = "#122739", -- Matches Neovim's 'Cursor' fg
		selection_bg = "#0052AA",
		split = palette.coblat_bg_dark,
		compose_cursor = palette.purple,
		tab_bar = {
			background = palette.cobalt_bg,
			active_tab = {
				fg_color = palette.light_yellow,
				bg_color = palette.cobalt_bg,
			},
			inactive_tab = {
				fg_color = palette.light_grey,
				intensity = "Half",
				italic = true,
				bg_color = palette.cobalt_bg,
			},
			new_tab = {
				bg_color = palette.cobalt_bg,
				fg_color = palette.light_grey,
			},
		},
	}

	config.default_cursor_style = "BlinkingBar"

	-- weight = 345 for a lighter weight.
	config.font = wezterm.font_with_fallback({
		{ family = "Operator Mono Lig", weight = 500 },
		{ family = "JetBrainsMono Nerd Font" },
	})

	config.font_size = 14
	config.cell_width = 1

	config.background = {
		{ source = { File = "/Users/schester/Pictures/mono_dark_distortion_1.jpeg" } },
		{
			source = { Color = "#162F43" },
			width = "100%",
			height = "100%",
			opacity = 0.95,
		},
	}

	config.inactive_pane_hsb = {
		saturation = 0.7,
		brightness = 0.6,
	}

	return config
end

return M
