local M = {}

local palette = {
	cobalt_bg = "#1C2E41",
	cobalt_bg_dark = "#15232D",
	cobalt_bg_light = "#2A3C51",
	purple = "#967EFB",
	light_yellow = "#FFC600",
	light_grey = "#9E9E9E",
	dim_blue_grey = "#506171",
	white = "#ffffff",
	black = "#1C1C1C",
	pink = "#FF628C",
	blue = "#00AAFF",
	green = "#7CDD7C",
	muted_red = "#E57373",
	greyish_blue = "#8fbfdc",
}

local theme = {
	background = palette.cobalt_bg,
	background_dark = palette.cobalt_bg_dark,
	background_light = palette.cobalt_bg_light,
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

	config.color_scheme = "Cobalt44"

	config.color_schemes = {
		Cobalt44 = {
			ansi = {
				palette.cobalt_bg_dark,
				palette.muted_red,
				palette.green,
				palette.light_yellow,
				palette.blue,
				palette.purple,
				palette.greyish_blue,
				palette.white,
			},
			brights = {
				palette.cobalt_bg_dark,
				palette.muted_red,
				palette.green,
				palette.light_yellow,
				palette.blue,
				palette.purple,
				palette.greyish_blue,
				palette.white,
			},
		},
	}

	config.colors = {
		background = theme.background,
		foreground = theme.foreground,
		cursor_fg = theme.background,
		cursor_bg = palette.light_yellow,
		selection_bg = theme.cursor_highlight,
		selection_fg = theme.background,
		split = theme.background_dark,
		compose_cursor = palette.purple,
		tab_bar = {
			background = theme.background,
			active_tab = {
				fg_color = theme.foreground_highlight,
				bg_color = theme.background_light,
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
		brightness = 0.5,
		saturation = 0.7,
	}

	return config
end

return M
