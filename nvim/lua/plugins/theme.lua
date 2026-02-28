local plugins = require 'lib/plugins'

-- Change this to switch themes: 'cobalt44' or 'graphite'
local active_theme = 'graphite'

return {
  {
    dir = plugins.custom_path 'cobalt44.nvim',
    cond = not vim.g.vscode and active_theme == 'cobalt44',
    dependencies = { 'tjdevries/colorbuddy.nvim', tag = 'v1.0.0' },
    priority = 1000,
    init = function()
      require('colorbuddy').colorscheme 'cobalt44'
    end,
  },
  {
    dir = plugins.custom_path 'graphite.nvim',
    cond = not vim.g.vscode and active_theme == 'graphite',
    dependencies = { 'tjdevries/colorbuddy.nvim', tag = 'v1.0.0' },
    priority = 1000,
    init = function()
      require('colorbuddy').colorscheme 'graphite'
    end,
  },
}
