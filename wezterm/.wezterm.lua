local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Cobalt2"

config.colors = {
	background = "#1C2E41",
}
config.default_cursor_style = "BlinkingBar"

config.font = wezterm.font("Operator Mono Lig", { weight = 345 })
config.font_size = 14
config.line_height = 1

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
	map_cmd_num("\x54"),
	-- Open new tmux window using cmd+t
	map_cmd_num("c"),
	-- Open tmux windows 1-9 using cmd+1-9
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
