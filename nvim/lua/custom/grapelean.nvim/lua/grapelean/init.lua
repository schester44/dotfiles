-- ╭──────────────────────────────────────────────────────────╮
-- │          Copyright (c) 2022-present Lalit Kumar          │
-- │                       License: MIT                       │
-- ╰──────────────────────────────────────────────────────────╯
--
local Color = require('grapelean.utils').Color
local palette = require 'grapelean.palette'
local M = {}

-- Convert a hex color (e.g., "#162F43") to RGB
local function hex_to_rgb(hex)
  hex = hex:gsub('#', '')
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

-- Convert RGB values to a hex color
local function rgb_to_hex(r, g, b)
  return string.format('#%02X%02X%02X', r, g, b)
end

-- Blend two colors (foreground and background) with a given alpha value
function M.blend(fg, bg, alpha)
  local r1, g1, b1 = hex_to_rgb(fg)
  local r2, g2, b2 = hex_to_rgb(bg)

  local r = math.floor((alpha * r1) + ((1 - alpha) * r2))
  local g = math.floor((alpha * g1) + ((1 - alpha) * g2))
  local b = math.floor((alpha * b1) + ((1 - alpha) * b2))

  return rgb_to_hex(r, g, b)
end

function M.adjust_transparency(hex_color, background, alpha)
  return M.blend(hex_color, background, alpha)
end

--------------------------------------------------------------------------------
-- Register all palette colors with colorbuddy
--------------------------------------------------------------------------------
for name, hex in pairs(palette) do
  Color.new(name, hex)
end

-- Background tints for highlights
Color.new('green_bg', M.adjust_transparency(palette.green, palette.bg, 0.1))
Color.new('red_bg', M.adjust_transparency(palette.red, palette.bg, 0.1))
Color.new('yellow_bg', M.adjust_transparency(palette.yellow, palette.bg, 0.1))
Color.new('blue_bg', M.adjust_transparency(palette.blue, palette.bg, 0.1))
Color.new('purple_bg', M.adjust_transparency(palette.purple, palette.bg, 0.1))
Color.new('pink_bg', M.adjust_transparency(palette.pink, palette.bg, 0.1))
Color.new('light_red_bg', M.adjust_transparency(palette.red_light, palette.bg, 0.15))
Color.new('light_blue_bg', M.adjust_transparency(palette.blue_light, palette.bg, 0.1))

--------------------------------------------------------------------------------
-- Load highlights
--------------------------------------------------------------------------------
require 'grapelean.theme'
require 'grapelean.syntax'
require 'grapelean.plugins'
require 'grapelean.languages'

-- vim:fdm=marker
