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
  dim_blue = '#506171',
}

local theme = {
  normal = {
    a = { fg = colors.white, bg = colors.bg },
    b = { fg = colors.white, bg = colors.bg },
    c = { fg = colors.blue },
    z = { fg = colors.dim_blue, bg = colors.bg },
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
    event = 'VeryLazy',
    config = function()
      require('lualine').setup {
        options = {
          theme = theme,
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = {
            {
              'filename',
              path = 1,
              file_status = false,
              padding = 0,
              fmt = function(str)
                local name = str:match '([^/]+)$' -- Extract the file name
                local relnotail = str:gsub(name, '') -- Remove the file name from the relative path

                return '%#StatusOther#' .. relnotail
              end,
            },
            {
              'filename',
              path = 1,
              padding = 0,
              fmt = function(str)
                local fullpath = str -- `str` contains the full file path
                local name = fullpath:match '([^/]+)$' -- Extract the file name

                return name
              end,
            },
          },
          lualine_b = {
            'diagnostics',
          },
          lualine_c = { { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available } },
          lualine_x = {},
          lualine_y = { 'branch', 'diff' },
          lualine_z = { { 'filetype', colored = false } },
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
      }
    end,
  },
}
