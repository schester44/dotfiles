local wezterm = require("wezterm")

local theme = require("theme")
local window = require("window")
local keymaps = require("keymaps")

local config = wezterm.config_builder()

theme.apply(config)
window.apply(config)
keymaps.apply(config)

return config
