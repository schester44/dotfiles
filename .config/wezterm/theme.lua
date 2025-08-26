local M = {}

local palette = {
	cobalt_bg = "#1C2E41",
	cobalt_bg_dark = "#15232D",
	purple = "#967EFB",
	light_yellow = "#FFEE80",
	light_grey = "#9E9E9E",
	dim_blue_grey = "#506171",
	white = "#ffffff",
	pink = "#FF628C",
	blue = "#0052AA",
}

local theme = {
	background = palette.cobalt_bg,
	background_dark = palette.cobalt_bg_dark,
	foreground_muted = palette.dim_blue_grey,
	foreground_inactive = palette.light_grey,
	foreground = palette.white,
	foreground_highlight = palette.light_yellow,
	alert = palette.pink,
	cursor_highlight = palette.blue,
}

M.theme = theme

function M.apply(config)
	local wezterm = require("wezterm")

	config.color_scheme = "Cobalt2"

	config.colors = {
		background = theme.background,
		cursor_fg = theme.background,
		selection_bg = theme.cursor_highlight,
		split = theme.background_dark,
		compose_cursor = palette.purple,
		tab_bar = {
			background = theme.background,
			active_tab = {
				fg_color = theme.foreground_highlight,
				intensity = "Bold",
				bg_color = theme.background,
			},
			inactive_tab = {
				fg_color = theme.foreground_inactive,
				italic = true,
				bg_color = theme.background,
			},
			new_tab = {
				bg_color = theme.background,
				fg_color = theme.foreground_inactive,
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

	config.inactive_pane_hsb = {
		saturation = 0,
		brightness = 0.4,
	}

	return config
end

return M
