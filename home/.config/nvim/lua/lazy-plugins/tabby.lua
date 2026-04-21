return {
  'nanozuki/tabby.nvim',
  config = function()
    require('tabby').setup {
      preset = 'tab_only',
    }

    local set = vim.api.nvim_set_keymap

    set('n', '<leader>tn', ':$tabnew<CR>', { noremap = true })
    set('n', '<leader>tc', ':tabclose<CR>', { noremap = true })
    set('n', '<leader>to', ':tabonly<CR>', { noremap = true })
    set('n', '<leader>tk', ':tabn<CR>', { noremap = true })
    set('n', '<leader>tj', ':tabp<CR>', { noremap = true })
    -- move current tab to previous position
    set('n', '<leader>tmp', ':-tabmove<CR>', { noremap = true })
    -- move current tab to next position
    set('n', '<leader>tmn', ':+tabmove<CR>', { noremap = true })

    set('n', '<leader>tt', ':Tabby jump_to_tab<CR>', { noremap = true })
  end,
}
