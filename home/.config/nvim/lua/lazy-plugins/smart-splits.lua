return {
  'mrjones2014/smart-splits.nvim',
  config = function()
    require('smart-splits').setup()

    -- these keymaps will also accept a range,
    -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`

    -- FIXME: - These conflict with Aerospace focus
    vim.keymap.set('n', '<C-Down>', require('smart-splits').resize_down)
    vim.keymap.set('n', '<C-Up>', require('smart-splits').resize_up)
    vim.keymap.set('n', '<C-Left>', require('smart-splits').resize_left)
    vim.keymap.set('n', '<C-Right>', require('smart-splits').resize_right)

    vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
    vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
    vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
    vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)

    vim.keymap.set('n', '<leader>bsl', require('smart-splits').swap_buf_left)
    vim.keymap.set('n', '<leader>bsj', require('smart-splits').swap_buf_down)
    vim.keymap.set('n', '<leader>bsk', require('smart-splits').swap_buf_up)
    vim.keymap.set('n', '<leader>bsl', require('smart-splits').swap_buf_right)
  end,
}
