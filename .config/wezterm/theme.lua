local M = {}

local palette = {
	bg = "#121214",
	bg_dark = "#101012",
	bg_light = "#2a2a2e",
	purple = "#967EFB",
	yellow = "#d4b870",
	gray_light = "#9E9E9E",
	gray_muted = "#626262",
	white = "#cccccc",
	black = "#1C1C1C",
	pink = "#FF628C",
	blue = "#8fbfdc",
	green = "#1bfd9c",
	red_muted = "#E57373",
	blue_muted = "#668799",
}

local inactive_panel_background = "#151517"

local theme = {
	background = palette.bg,
	background_dark = palette.bg_dark,
	background_light = palette.bg_light,
	foreground_muted = palette.gray_muted,
	foreground_inactive = palette.gray_light,
	foreground = palette.white,
	foreground_highlight = palette.yellow,
	alert = palette.pink,
	cursor_highlight = palette.blue,
	inactive_panel_background = inactive_panel_background,
}

M.theme = theme

function M.apply(config)
	local wezterm = require("wezterm")

	config.color_scheme = "Cobalt44"

	config.color_schemes = {
		Cobalt44 = {
			ansi = {
				palette.bg_dark,      -- 0: black
				palette.red_muted,    -- 1: red
				palette.green,        -- 2: green
				palette.yellow,       -- 3: yellow
				palette.blue,         -- 4: blue
				palette.purple,       -- 5: purple
				palette.blue_muted,   -- 6: cyan
				palette.white,        -- 7: white
			},
			brights = {
				palette.gray_light,   -- 8: bright black (gray)
				palette.red_muted,    -- 9: bright red
				palette.green,        -- 10: bright green
				palette.yellow,       -- 11: bright yellow
				palette.blue,         -- 12: bright blue
				palette.purple,       -- 13: bright purple
				palette.blue_muted,   -- 14: bright cyan
				palette.white,        -- 15: bright white
			},
		},
	}

	config.colors = {
		background = theme.background,
		foreground = theme.foreground,
		cursor_fg = theme.background,
		cursor_bg = palette.yellow,
		selection_bg = palette.bg_light,
		selection_fg = theme.foreground,
		split = theme.background_dark,
		compose_cursor = palette.purple,
		tab_bar = {
			background = inactive_panel_background,
			active_tab = {
				fg_color = theme.foreground_highlight,
				bg_color = "#2a2a2e",
			},
			inactive_tab = {
				fg_color = theme.foreground_inactive,
				italic = true,
				bg_color = inactive_panel_background,
			},
			new_tab = {
				bg_color = inactive_panel_background,
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
		brightness = 0.4,
		saturation = 0.8,
	}

	return config
end

return M
