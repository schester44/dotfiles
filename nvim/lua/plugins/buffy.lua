local plugins = require 'lib/plugins'

return {
  {
    dir = plugins.custom_path 'buffy.nvim',
    cond = not vim.g.vscode,
    priority = 1000,
    init = function()
      require('buffy').setup()
    end,
  },
}
