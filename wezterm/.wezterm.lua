local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Cobalt2"

config.colors = {
	background = "#1C2E41",
	cursor_fg = "#122739", -- Matches Neovim's 'Cursor' fg
}

config.default_cursor_style = "BlinkingBar"

-- weight = 345 for a lighter weight.
config.font = wezterm.font("Operator Mono Lig", { weight = 400 })
config.font_size = 14

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.window_background_opacity = 0.95

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
