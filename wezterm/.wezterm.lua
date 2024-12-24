local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Cobalt2"

config.colors = {
	background = "#1C2E41",
}
config.default_cursor_style = "BlinkingBar"

config.font = wezterm.font("Operator Mono Lig", { weight = 345 })
config.font_size = 14
config.line_height = 1.1

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.window_background_opacity = 0.95

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
}

return config
