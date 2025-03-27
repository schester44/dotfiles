local plugins = require 'lib/plugins'

return {
  {
    dir = plugins.custom_path 'cobalt44.nvim',
    cond = not vim.g.vscode,
    dependencies = { 'tjdevries/colorbuddy.nvim', tag = 'v1.0.0' },
    priority = 1000,
    init = function()
      require('colorbuddy').colorscheme 'cobalt44'
    end,
  },
}
