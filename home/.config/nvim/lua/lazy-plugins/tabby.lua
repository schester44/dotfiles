return {
  'nanozuki/tabby.nvim',
  config = function()
    require('tabby').setup {
      preset = 'tab_only',
    }

    local set = vim.api.nvim_set_keymap

    set('n', '<leader>tc', ':tabclose<CR>', { noremap = true, desc = "Close tab" })
  end,
}
