return {
  'Goose97/timber.nvim',
  version = '*',
  event = 'VeryLazy',
  config = function()
    vim.keymap.set('n', 'glc', function()
      require('timber.actions').clear_log_statements { global = false }
    end, { desc = 'Clear all logs in buffer' })

    require('timber').setup {
      log_templates = {
        default = {
          lua = [[print("%log_marker %log_target", %log_target)]],
          javascript = [[console.log("\x1b[33m%s\x1b[0m %s", "%log_marker %log_target", %log_target)]],
          typescript = [[console.log("\x1b[33m%s\x1b[0m %s", "%log_marker %log_target", %log_target)]],
          jsx = [[console.log("%log_marker %log_target", %log_target)]],
          tsx = [[console.log("%log_marker %log_target", %log_target)]],
        },
        plain = {
          javascript = [[console.log("\x1b[33m%s\x1b[0m %s", "%log_marker", %insert_cursor)]],
          typescript = [[console.log("\x1b[33m%s\x1b[0m %s", "%log_marker", %insert_cursor)]],
          jsx = [[console.log("%log_marker", %insert_cursor)]],
          tsx = [[console.log("%log_marker", %insert_cursor)]],
          lua = [[print("%log_marker", %insert_cursor)]],
        },
      },
      log_marker = '🪵',
    }
    vim.keymap.set('n', 'gll', function()
      return require('timber.actions').insert_log { position = 'below', operator = true } .. '_'
    end, {
      desc = '[G]o [L]og: Insert below log statements the current line',
      expr = true,
    })
  end,
}
