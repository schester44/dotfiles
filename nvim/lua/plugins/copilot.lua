return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cond = not vim.g.vscode,
    config = function()
      local palette = require 'cobalt44.palette'

      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = palette.grey, bg = nil })
      vim.api.nvim_set_hl(0, 'CopilotAnnotation', { fg = palette.grey, bg = nil })

      require('copilot').setup {
        suggestion = { enabled = true, auto_trigger = true },
        panel = { enabled = true, keymap = {
          open = '<M-0>',
        } },
      }
    end,
  },
}
