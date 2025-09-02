return {
  'echasnovski/mini.bufremove',
  cond = not vim.g.vscode,
  version = '*',
  config = function()
    require('mini.bufremove').setup()

    -- Better buffer deletion
    vim.keymap.set('n', '<leader>bd', function()
      require('mini.bufremove').delete(0, false)
    end, { desc = 'Delete Buffer' })

    vim.keymap.set('n', '<leader>bD', function()
      require('mini.bufremove').delete(0, true)
    end, { desc = 'Delete Buffer (Force)' })

    vim.keymap.set('n', '<leader>ba', function()
      local current = vim.api.nvim_get_current_buf()
      local buffers = vim.api.nvim_list_bufs()
      
      for _, buf in ipairs(buffers) do
        if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
          require('mini.bufremove').delete(buf, false)
        end
      end
    end, { desc = 'Delete All Other Buffers' })
  end,
}