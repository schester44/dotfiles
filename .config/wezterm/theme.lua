-- Grapelean theme for WezTerm
-- Loads from ~/.dotfiles/colors/grapelean.json (single source of truth)

local wezterm = require("wezterm")
local M = {}

local json_path = os.getenv("HOME") .. "/.dotfiles/colors/grapelean.json"

-- Watch the JSON file for changes (triggers config reload)
wezterm.add_to_config_reload_watch_list(json_path)

local function load_json(path)
	local file = io.open(path, "r")
	if not file then
		error("Could not open palette file: " .. path)
	end
	local content = file:read("*a")
	file:close()

	return wezterm.json_parse(content)
end

local theme_data = load_json(json_path)
local p = theme_data.palette
local t = theme_data.terminal
local s = theme_data.semantic

local palette = {
	bg = p.bg.base,
	bg_dark = p.bg.dark,
	bg_light = p.bg.light,
	purple = p.purple.base,
	yellow = p.yellow.base,
	gray_light = p.gray.light,
	gray_muted = p.gray.muted,
	white = p.white,
	black = p.black,
	pink = p.pink.base,
	blue = p.blue.base,
	green = p.green.glow,
	red_muted = p.red.muted,
	blue_muted = p.blue.muted,
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

	config.color_scheme = "Grapelean"

	config.color_schemes = {
		Grapelean = {
			ansi = {
				t.black,   -- 0: black
				t.red,     -- 1: red
				t.green,   -- 2: green
				t.yellow,  -- 3: yellow
				t.blue,    -- 4: blue
				t.purple,  -- 5: purple
				t.cyan,    -- 6: cyan
				t.white,   -- 7: white
			},
			brights = {
				t.bright_black,   -- 8: bright black (gray)
				t.bright_red,     -- 9: bright red
				t.bright_green,   -- 10: bright green
				t.bright_yellow,  -- 11: bright yellow
				t.bright_blue,    -- 12: bright blue
				t.bright_purple,  -- 13: bright purple
				t.bright_cyan,    -- 14: bright cyan
				t.bright_white,   -- 15: bright white
			},
		},
	}

	config.colors = {
		background = theme.background,
		foreground = theme.foreground,
		cursor_fg = theme.background,
		cursor_bg = s.cursor,
		selection_bg = s.selection,
		selection_fg = theme.foreground,
		split = theme.background_dark,
		compose_cursor = palette.purple,
		tab_bar = {
			background = inactive_panel_background,
			active_tab = {
				fg_color = theme.foreground_highlight,
				bg_color = palette.bg_light,
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
