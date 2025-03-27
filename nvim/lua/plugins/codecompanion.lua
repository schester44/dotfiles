return {
  'olimorris/codecompanion.nvim',
  cond = not vim.g.vscode,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>cc', '<cmd>CodeCompanion<CR>',
      { noremap = true, silent = true, desc = 'Code Companion' })
    vim.api.nvim_set_keymap('v', '<leader>cc', ":'<,'>CodeCompanion<CR>",
      { noremap = true, silent = true, desc = 'Code Companion' })
    vim.api.nvim_set_keymap('n', '<leader>cC', '<cmd>CodeCompanionChat<CR>',
      { noremap = true, silent = true, desc = 'Code Companion Chat' })

    require('codecompanion').setup {
      display = {
        chat = {
          show_settings = true,
        },
      },
      strategies = {
        chat = {
          adapter = 'anthropic',
        },
        inline = {
          adapter = 'copilot',
        },
      },
    }
  end,
}
