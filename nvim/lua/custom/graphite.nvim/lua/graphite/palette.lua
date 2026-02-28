-- Structured color palette
-- Pattern: x, x_dark, x_light, x_muted

local colors = {
  -- backgrounds
  bg = '#141416',
  bg_dark = '#252528',
  bg_light = '#2e2e32',
  bg_muted = '#1c1c20',

  -- gray
  gray = '#808080',
  gray_dark = '#444444',
  gray_light = '#9E9E9E',
  gray_muted = '#626262',

  -- white/black
  black = '#0a0a0c',
  white = '#c0c0c0',

  -- keywords (neutral light gray)
  keyword = '#888890',

  -- yellow (functions, important)
  yellow = '#d4b870',
  yellow_dark = '#b89840',
  yellow_light = '#e0cfa0',
  yellow_muted = '#d4a055',

  -- green (strings)
  green = '#5fcf9f',
  green_dark = '#3a9a7a',
  green_light = '#7fe8b8',
  green_muted = '#4db88a',

  -- blue (types)
  blue = '#8fbfdc',
  blue_dark = '#345FA8',
  blue_light = '#80FCFF',
  blue_muted = '#668799',

  -- purple
  purple = '#967EFB',
  purple_dark = '#6a5acd',
  purple_light = '#b8a8e8',
  purple_muted = '#7d70ba',

  -- red
  red = '#FF6B6B',
  red_dark = '#902020',
  red_light = '#ffa0a0',
  red_muted = '#E57373',

  -- pink
  pink = '#FF628C',
  pink_dark = '#c44a6c',
  pink_light = '#FF68B8',
  pink_muted = '#d87090',

  -- cursor
  cursor_line = '#222226',
  cursor_hover = '#2a2a2e',

  --============================================================================
  -- Legacy aliases (for compatibility)
  --============================================================================
  cobalt_bg = '#141416',
  cobalt_bg_dark = '#252528',
  cobalt_bg_light = '#2e2e32',
  cobalt_bg_lighter = '#3e3e42',
  
  dark_grey = '#626262',
  darker_grey = '#444444',
  light_grey = '#9E9E9E',
  grey = '#808080',
  
  dark_orange = '#d4a055',
  light_orange = '#d4a055',
  light_yellow = '#e0cfa0',
  
  light_blue = '#80FCFF',
  dark_blue = '#345FA8',
  
  dark_purple = '#6a5acd',
  light_purple = '#b8a8e8',
  
  dark_pink = '#FF628C',
  light_pink = '#FF68B8',
  
  dark_red = '#902020',
  light_red = '#ffa0a0',
  muted_red = '#E57373',
  
  -- additional legacy
  dim_blue = '#a8a8ab',
  lighter_grey = '#BCBCBC',
  darker_blue = '#0050A4',
  darkest_blue = '#0000df',
  dirty_pink = '#EB939A',
  lightest_pink = '#FFA5F3',
  aubergine = '#4F0037',
  orange = '#d4a055',
}

return colors
