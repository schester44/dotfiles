local ui = require 'lib.ui'

return {
  'stevearc/oil.nvim',
  cond = not vim.g.vscode,
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  config = function()
    require('oil').setup {
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == '.git' or name == '.DS_Store'
        end,
      },
      float = { padding = 2, max_width = 120, max_height = 50, border = ui.border_chars_outer_thin },

      keymaps = {
        ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
      },
    }

    vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = 'Open parent directory' })
  end,
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
