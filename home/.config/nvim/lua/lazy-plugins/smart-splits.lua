return {
  'mrjones2014/smart-splits.nvim',
  dependencies = { 'smart-splits-nvim/backend-wezterm' },
  config = function()
    require('smart-splits').setup({
      mux = { backend = 'smart-splits-backend-wezterm' },
    })

    -- these keymaps will also accept a range,
    -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`

    -- Alt+hjkl matches the wezterm backend plugin, which forwards META+hjkl to nvim
    vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
    vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
    vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
    vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)

    vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
    vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
    vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
    vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)

    vim.keymap.set('n', '<leader>bsh', require('smart-splits').swap_buf_left)
    vim.keymap.set('n', '<leader>bsj', require('smart-splits').swap_buf_down)
    vim.keymap.set('n', '<leader>bsk', require('smart-splits').swap_buf_up)
    vim.keymap.set('n', '<leader>bsl', require('smart-splits').swap_buf_right)
  end,
}
