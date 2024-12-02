return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    config = function()
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#555555', bg = '#ff0000', italic = true })
      vim.api.nvim_set_hl(0, 'CopilotAnnotation', { fg = '#555555', bg = '#ff0000', italic = true })

      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
