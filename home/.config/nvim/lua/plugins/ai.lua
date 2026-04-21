local plugins = require 'lib.plugins'

plugins.add {
  {
    src = 'zbirenbaum/copilot.lua',
    name = 'copilot',
    opts = function(ctx)
      print('Setting up ' .. ctx.name)
      local palette = require 'grapelean.palette'

      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = palette.gray, bg = nil })
      vim.api.nvim_set_hl(0, 'CopilotAnnotation', { fg = palette.gray, bg = nil })

      require('copilot').setup {
        suggestion = { enabled = true, auto_trigger = true },
        panel = { enabled = true, keymap = {
          open = '<M-0>',
        } },
      }
    end,
  },
}
