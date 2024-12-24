return {
  'stevearc/oil.nvim',
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  config = function()
    require('oil').setup {
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == '.git' or name == '.DS_Store'
        end,
      },
      float = { padding = 2, max_width = 120, max_height = 0 },
    }

    vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = 'Open parent directory' })
  end,
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
