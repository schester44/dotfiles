local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Cobalt2"

config.colors = {
	background = "#1C2E41",
	cursor_fg = "#122739", -- Matches Neovim's 'Cursor' fg
}

config.default_cursor_style = "BlinkingBar"

-- weight = 345 for a lighter weight.
config.font = wezterm.font_with_fallback({
	{ family = "Operator Mono Lig", weight = 400 },
	{ family = "JetBrainsMono Nerd Font" },
})

config.font_size = 14
config.cell_width = 1

config.enable_tab_bar = false

config.background = {
	{ source = { File = "/Users/schester/Pictures/mono_dark_distortion_1.jpeg" } },
	{
		source = { Color = "#162F43" },
		width = "100%",
		height = "100%",
		opacity = 0.95,
	},
}

config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 4,
	bottom = 0,
}

-- @param num number
-- return { key = string, mods = string, action = wezterm.action }
local function map_cmd_num(num)
	return {
		key = num,
		mods = "CMD",
		action = wezterm.action.SendString("\x01" .. num),
	}
end

config.keys = {
	-- Fuzzy find tmux sessions using cmd+k
	{
		key = "k",
		mods = "CMD",
		action = wezterm.action.SendString("\x01\x54"),
	},
	-- Open new tmux window using cmd+t
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.SendString("\x01c"),
	},
	map_cmd_num("1"),
	map_cmd_num("2"),
	map_cmd_num("3"),
	map_cmd_num("4"),
	map_cmd_num("5"),
	map_cmd_num("6"),
	map_cmd_num("7"),
	map_cmd_num("8"),
	map_cmd_num("9"),
}

return config
