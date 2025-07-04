local tools = require 'lib.tools'

local get_theme = function()
  local palette = require 'cobalt44.palette'

  local colors = {
    fg_bright = palette.lighter_grey,
    fg_dim = palette.dim_blue,
    red = palette.red,
    violet = palette.light_pink,
    bg = palette.cobalt_bg,
    yellow = palette.yellow,
  }

  local active_theme = { fg = colors.fg_dim, bg = nil }
  local inactive_theme = { fg = colors.fg_dim, bg = nil }

  return {
    normal = {
      a = active_theme,
      b = { fg = colors.fg_bright, bg = colors.bg },
      c = active_theme,
      x = active_theme,
      y = active_theme,
      z = active_theme,
    },

    insert = { a = { fg = colors.violet, bg = colors.bg } },
    visual = { a = { fg = colors.yellow, bg = colors.bg } },
    replace = { a = { fg = colors.red, bg = colors.bg } },

    inactive = {
      a = inactive_theme,
      b = inactive_theme,
      c = inactive_theme,
      x = inactive_theme,
      y = inactive_theme,
      z = inactive_theme,
    },
  }
end

local function copilot_status()
  local c = require 'copilot.client'
  local icons = require 'lib.icons'
  local ok = not c.is_disabled() and c.buf_is_attached(vim.api.nvim_get_current_buf())

  if not ok then
    return tools.hl_str('LualineCopilotOffline', icons.kinds.CopilotOffline)
  end

  return icons.kinds.CopilotOnline
end

local macro_recording = function()
  local reg = vim.fn.reg_recording()

  if reg == '' then
    return ''
  end

  return tools.hl_str('LualineRecording', ' Recording @' .. reg)
end

return {
  {
    'nvim-lualine/lualine.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/snacks.nvim' },
    event = 'VeryLazy',
    config = function()
      -- adds a border for inactive windows
      vim.opt.fillchars = {
        stl = ' ',
        stlnc = '─',
        diff = '╱',
      }

      require('lualine').setup {
        options = {
          theme = get_theme(),
          always_show_tabline = false,
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        extensions = { 'trouble' },
        sections = {
          lualine_a = {
            macro_recording,
            {
              'filename',
              path = 1,
              file_status = false,
              fmt = function(name)
                local fname = vim.fn.fnamemodify(name, ':t')
                local path = vim.fn.fnamemodify(name, ':p:h')

                return (path ~= '' and tools.hl_str('LualinePath', path .. '/') or '')
                  .. tools.hl_str(vim.bo.modified and 'LualineFilenameModified' or 'LualineFilename', (vim.bo.modified and '+' or '') .. fname)
              end,
            },
          },
          lualine_b = {
            'diagnostics',
          },
          lualine_c = {
            -- '%=', - to center a section
          },
          lualine_x = {
            Snacks.profiler.status(),
          },
          lualine_y = { 'branch' },
          lualine_z = { copilot_status, require 'mcphub.extensions.lualine' },
        },
        inactive_sections = {
          lualine_a = {
            {
              'filename',
              path = 1,
              file_status = false,
            },
          },
          lualine_b = { 'diagnostics' },
          lualine_c = {},
          lualine_x = {},
          lualine_y = { 'branch' },
          lualine_z = {},
        },
      }
    end,
  },
}
