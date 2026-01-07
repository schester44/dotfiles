local wezterm = require("wezterm")

local theme = require("theme")
local window = require("window")
local keymaps = require("keymaps")

local config = wezterm.config_builder()

keymaps.apply(config)
theme.apply(config)
window.apply(config)

-- Not sure why this exists yet, but we need to merge config.keys, not replace it
-- config.keys = {-- 	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r",
-- {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},}) },
-- }

return config
