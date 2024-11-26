local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Cobalt2"

config.colors = {
	background = "#1C2E41",
}

config.font = wezterm.font("Operator Mono Lig", { weight = 325 })
config.font_size = 13

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

return config
