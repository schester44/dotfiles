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

return config
