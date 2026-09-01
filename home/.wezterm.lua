local wezterm = require("wezterm")

local theme = require("theme")
local window = require("window")
local keymaps = require("keymaps")
local resurrect = require("resurrect")

local config = wezterm.config_builder()

keymaps.apply(config)
theme.apply(config)
window.apply(config)
resurrect.apply(config) -- must come after keymaps (appends to config.keys)

config.enable_wayland = false
config.enable_kitty_keyboard = true
config.audible_bell = "SystemBeep"

-- Not sure why this exists yet, but we need to merge config.keys, not replace it
-- config.keys = {-- 	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r",
-- {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},}) },
-- }

return config
