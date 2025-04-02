-- ╭──────────────────────────────────────────────────────────╮
-- │          Copyright (c) 2022-present Lalit Kumar          │
-- │                       License: MIT                       │
-- ╰──────────────────────────────────────────────────────────╯
--
local Color = require('cobalt44.utils').Color
local palette = require 'cobalt44.palette'
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

  -- Perform alpha blending
  local r = math.floor((alpha * r1) + ((1 - alpha) * r2))
  local g = math.floor((alpha * g1) + ((1 - alpha) * g2))
  local b = math.floor((alpha * b1) + ((1 - alpha) * b2))

  return rgb_to_hex(r, g, b)
end

-- Adjust the transparency of a color by blending it with a base color
function M.adjust_transparency(hex_color, background, alpha)
  return M.blend(hex_color, background, alpha)
end

Color.new('light_orange_bg', M.adjust_transparency(palette.light_orange, palette.cobalt_bg, 0.1))
Color.new('light_purple_bg', M.adjust_transparency(palette.purple, palette.cobalt_bg, 0.1))
Color.new('light_green_bg', M.adjust_transparency(palette.light_green, palette.cobalt_bg, 0.1))
Color.new('light_blue_bg', M.adjust_transparency(palette.light_blue, palette.cobalt_bg, 0.1))
Color.new('light_pink_bg', M.adjust_transparency(palette.light_pink, palette.cobalt_bg, 0.1))
Color.new('light_yellow_bg', M.adjust_transparency(palette.light_yellow, palette.cobalt_bg, 0.1))

--------------------------------------------------------------------------------
--  NOTE: colors {{{
--------------------------------------------------------------------------------
Color.new('cobalt_bg_light', palette.cobalt_bg_light)
Color.new('cobalt_bg_lighter', palette.cobalt_bg_lighter)
Color.new('cobalt_bg_dark', palette.cobalt_bg_dark)
Color.new('cobalt_bg', palette.cobalt_bg)

Color.new('light_blue_green', palette.light_blue_green)
Color.new('black', palette.black)
Color.new('darkest_grey', palette.darkest_grey)
Color.new('darker_grey', palette.darker_grey)
Color.new('dark_grey', palette.dark_grey)
Color.new('grey', palette.grey)
Color.new('light_grey', palette.light_grey)
Color.new('lighter_grey', palette.lighter_grey)
Color.new('lightest_grey', palette.lightest_grey)
Color.new('white', palette.white)
Color.new('dark_orange', palette.dark_orange)
Color.new('light_orange', palette.light_orange)
Color.new('yellow', palette.yellow)
Color.new('light_yellow', palette.light_yellow)
Color.new('darkest_green', palette.darkest_green)
Color.new('dirty_green', palette.dirty_green)
Color.new('green', palette.green)
Color.new('light_green', palette.light_green)
Color.new('lighter_green', palette.lighter_green)
Color.new('lightest_green', palette.lightest_green)
Color.new('dark_purple', palette.dark_purple)
Color.new('purple', palette.purple)
Color.new('light_purple', palette.light_purple)
Color.new('darkest_blue', palette.darkest_blue)
Color.new('darker_blue', palette.darker_blue)
Color.new('dark_blue', palette.dark_blue)
Color.new('blue', palette.blue)
Color.new('light_blue', palette.light_blue)
Color.new('greyish_blue', palette.greyish_blue)
Color.new('dirty_blue', palette.dirty_blue)
Color.new('aubergine', palette.aubergine)
Color.new('darker_red', palette.darker_red)
Color.new('dark_red', palette.dark_red)
Color.new('red', palette.red)
Color.new('light_red', palette.light_red)
Color.new('muted_red', palette.muted_red)
Color.new('dark_pink', palette.dark_pink)
Color.new('pink', palette.pink)
Color.new('light_pink', palette.light_pink)
Color.new('lightest_pink', palette.lightest_pink)
Color.new('pale_pink', palette.pale_pink)
Color.new('dirty_pink', palette.dirty_pink)
Color.new('cursor_line', palette.cursor_line)
Color.new('cursor_hover', palette.cursor_hover)
Color.new('dim_blue', palette.dim_blue)
-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  NOTE: highlights {{{
--------------------------------------------------------------------------------
require 'cobalt44.theme'
require 'cobalt44.syntax'
require 'cobalt44.plugins'
require 'cobalt44.languages'
-- }}}
--------------------------------------------------------------------------------

-- vim:fdm=marker
