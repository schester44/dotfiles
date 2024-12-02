local colors = {
  blue = '#80a0ff',
  cyan = '#9BFAFB',
  black = '#080808',
  white = '#c6c6c6',
  red = '#ff5189',
  violet = '#FF68B8',
  grey = '#303030',
  bg = '#1C2E41',
  yellow = '#FFC600',
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.cyan, bg = colors.bg },
    b = { fg = colors.white, bg = colors.bg },
    c = { fg = colors.blue },
  },

  insert = { a = { fg = colors.violet, bg = colors.bg } },
  visual = { a = { fg = colors.yellow, bg = colors.bg } },
  replace = { a = { fg = colors.red, bg = colors.bg } },

  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.white },
  },
}

local git_blame = require 'gitblame'

-- This disables showing of the blame text next to the cursor
vim.g.gitblame_display_virtual_text = 0

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = bubbles_theme,
        component_separators = '',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {
          {
            'filename',
          },
        },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } },
        lualine_x = {},
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {},
    },
  },
}
