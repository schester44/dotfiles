-- Grapelean color palette
-- Loads from ~/.dotfiles/colors/grapelean.json (single source of truth)

local json_path = vim.fn.expand '~/.dotfiles/colors/grapelean.json'

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
-- Pattern: color = base, color_dark, color_light, color_muted
local colors = {
  -- backgrounds
  bg = p.bg.base,
  bg_dark = p.bg.dark,
  bg_light = p.bg.light,
  bg_lighter = p.bg.lighter,
  bg_muted = p.bg.muted,

  -- gray
  gray = p.gray.base,
  gray_dark = p.gray.dark,
  gray_light = p.gray.light,
  gray_muted = p.gray.muted,

  -- white/black
  black = p.black,
  white = p.white,

  -- keywords (semantic)
  keyword = s.keyword,

  -- yellow (functions, important)
  yellow = p.yellow.base,
  yellow_dark = p.yellow.dark,
  yellow_light = p.yellow.light,
  yellow_muted = p.yellow.muted,

  -- green (strings)
  green = p.green.base,
  green_dark = p.green.dark,
  green_light = p.green.light,
  green_muted = p.green.muted,
  green_glow = p.green.glow,

  -- blue (types)
  blue = p.blue.base,
  blue_dark = p.blue.dark,
  blue_light = p.blue.light,
  blue_muted = p.blue.muted,

  -- purple
  purple = p.purple.base,
  purple_dark = p.purple.dark,
  purple_light = p.purple.light,
  purple_muted = p.purple.muted,

  -- red
  red = p.red.base,
  red_dark = p.red.dark,
  red_light = p.red.light,
  red_muted = p.red.muted,

  -- pink
  pink = p.pink.base,
  pink_dark = p.pink.dark,
  pink_light = p.pink.light,
  pink_muted = p.pink.muted,

  -- cursor (semantic)
  cursor_line = s.cursor_line,
  cursor_hover = s.selection,
}

return colors
