local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')

return {
  dir = plugin_dir .. '/../custom/timber.nvim',
  name = 'timber.nvim',
  event = 'VeryLazy',
  config = function()
    vim.keymap.set('n', 'glc', function()
      require('timber.actions').clear_log_statements { global = false }
    end, { desc = 'Clear all logs in buffer' })

    vim.keymap.set('n', 'gll', function()
      return require('timber.actions').insert_log { position = 'below', operator = true } .. '_'
    end, {
      desc = '[G]o [L]og: Insert below log statements the current line',
      expr = true,
    })
  end,
}
