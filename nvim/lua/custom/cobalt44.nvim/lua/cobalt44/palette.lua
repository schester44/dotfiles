-- Cobalt44 color palette
-- Loads from ~/.dotfiles/colors/cobalt44.json (single source of truth)

local json_path = vim.fn.expand '~/.dotfiles/colors/cobalt44.json'

local function load_json(path)
  local file = io.open(path, 'r')
  if not file then
    error('Could not open palette file: ' .. path)
  end
  local content = file:read '*a'
  file:close()
  return vim.json.decode(content)
end

local theme = load_json(json_path)
local p = theme.palette
local s = theme.semantic

-- Flatten palette into the format expected by the theme
-- Maps JSON structure to legacy color names used throughout the theme
local colors = {
  -- backgrounds
  bg = p.bg.base,
  bg_dark = p.bg.dark,
  bg_light = p.bg.light,
  bg_lighter = p.bg.lighter,
  dim_blue = p.bg.muted,

  -- grays
  darkest_grey = p.gray.darkest,
  darker_grey = p.gray.darker,
  dark_grey = p.gray.dark,
  grey = p.gray.base,
  light_grey = p.gray.base,
  lighter_grey = p.gray.lighter,
  lightest_grey = p.gray.lightest,

  -- black/white
  black = p.black,
  white = p.white,

  -- orange
  orange = p.orange.base,
  dark_orange = p.orange.dark,
  light_orange = p.orange.light,

  -- yellow
  yellow = p.yellow.base,
  light_yellow = p.yellow.light,
  tainted_yellow = p.yellow.muted,

  -- green
  green = p.green.base,
  darkest_green = p.green.dark,
  light_green = p.green.light,
  lighter_green = p.green.lighter,
  lightest_green = p.green.lightest,

  -- blue
  blue = p.blue.base,
  dark_blue = p.blue.dark,
  darker_blue = p.blue.darker,
  light_blue = p.blue.light,
  dirty_blue = p.blue.muted,

  -- purple
  purple = p.purple.base,
  dark_purple = p.purple.dark,
  light_purple = p.purple.light,

  -- red
  red = p.red.base,
  dark_red = p.red.dark,
  darker_red = p.red.darker,
  light_red = p.red.light,
  muted_red = p.red.muted,

  -- pink
  pink = p.pink.base,
  dark_pink = p.pink.dark,
  light_pink = p.pink.light,
  lightest_pink = p.pink.lightest,
  pale_pink = p.pink.pale,

  -- cursor (semantic)
  cursor_line = s.cursor_line,
  cursor_hover = s.selection,
}

return colors
