local color = require 'grapelean.color'
local blend = color.blend

local json_path = vim.fn.expand '~/.dotfiles/system/theme.json'

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
local p_raw = theme.palette
local s_raw = theme.semantic

local palette = {
  bg = p_raw.bg.base,
  bg_dark = p_raw.bg.dark,
  bg_light = p_raw.bg.light,
  bg_lighter = p_raw.bg.lighter,
  bg_muted = p_raw.bg.muted,

  gray = p_raw.gray.base,
  gray_dark = p_raw.gray.dark,
  gray_light = p_raw.gray.light,
  gray_muted = p_raw.gray.muted,

  black = p_raw.black,
  white = p_raw.white,

  orange = p_raw.orange.base,
  orange_dark = p_raw.orange.dark,
  orange_light = p_raw.orange.light,

  yellow = p_raw.yellow.base,
  yellow_dark = p_raw.yellow.dark,
  yellow_light = p_raw.yellow.light,
  yellow_muted = p_raw.yellow.muted,

  green = p_raw.green.base,
  green_dark = p_raw.green.dark,
  green_light = p_raw.green.light,
  green_muted = p_raw.green.muted,
  green_glow = p_raw.green.glow,

  blue = p_raw.blue.base,
  blue_dark = p_raw.blue.dark,
  blue_light = p_raw.blue.light,
  blue_muted = p_raw.blue.muted,

  purple = p_raw.purple.base,
  purple_dark = p_raw.purple.dark,
  purple_light = p_raw.purple.light,
  purple_muted = p_raw.purple.muted,

  red = p_raw.red.base,
  red_dark = p_raw.red.dark,
  red_light = p_raw.red.light,
  red_muted = p_raw.red.muted,

  pink = p_raw.pink.base,
  pink_dark = p_raw.pink.dark,
  pink_light = p_raw.pink.light,
  pink_muted = p_raw.pink.muted,
}

palette.green_bg          = blend(palette.green,      palette.bg, 0.1)
palette.green_bg_emphasis = blend(palette.green,      palette.bg, 0.2)
palette.red_bg            = blend(palette.red,        palette.bg, 0.1)
palette.red_bg_emphasis   = blend(palette.red,        palette.bg, 0.2)
palette.yellow_bg         = blend(palette.yellow,     palette.bg, 0.1)
palette.blue_bg           = blend(palette.blue,       palette.bg, 0.1)
palette.purple_bg         = blend(palette.purple,     palette.bg, 0.1)
palette.pink_bg           = blend(palette.pink,       palette.bg, 0.1)
palette.red_light_bg      = blend(palette.red_light,  palette.bg, 0.15)
palette.blue_light_bg     = blend(palette.blue_light, palette.bg, 0.1)

local semantic = {
  bg             = palette.bg,
  bg_float       = palette.bg_dark,
  bg_visual      = palette.bg_lighter,
  bg_cursorline  = s_raw.cursor_line,
  bg_selection   = s_raw.selection,
  fg             = palette.white,
  fg_muted       = palette.gray_muted,
  fg_dim         = palette.gray,
  border         = palette.bg_dark,

  keyword          = s_raw.keyword,
  string           = palette.green,
  func             = palette.yellow,
  type             = palette.purple,
  constant         = palette.purple,
  number           = palette.purple,
  boolean          = palette.purple,
  comment          = palette.gray_muted,
  operator         = palette.gray_muted,
  delimiter        = palette.gray,
  parameter        = palette.white,
  property         = palette.white,
  variable         = palette.white,
  module           = palette.white,
  constructor      = palette.blue,
  special          = palette.blue,
  escape           = palette.blue,
  tag              = palette.green,
  tag_builtin      = palette.green,
  tag_attribute    = palette.yellow,
  tag_delimiter    = palette.white,
  macro            = palette.blue,
  label            = palette.gray,
  include          = s_raw.keyword,
  exception        = s_raw.keyword,
  conditional      = s_raw.keyword,
  loop             = s_raw.keyword,
  keyword_return   = palette.pink,
  keyword_function = s_raw.keyword,
  keyword_operator = palette.gray,
  keyword_coroutine = s_raw.keyword,
  builtin_constant = palette.pink,
  builtin_type     = palette.green,
  builtin_function = palette.yellow,

  error   = palette.red_muted,
  warning = palette.yellow_light,
  info    = palette.blue_light,
  hint    = palette.pink_light,

  added    = palette.green,
  modified = palette.yellow,
  removed  = palette.red_muted,

  search         = palette.blue,
  search_current = palette.pink_light,
  match          = palette.purple_dark,

  accent       = palette.pink,
  accent_alt   = palette.yellow,
  accent_muted = s_raw.keyword,
}

return {
  palette  = palette,
  semantic = semantic,
}
