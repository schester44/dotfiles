return {
  dir = '~/.dotfiles/nvim/lua/custom/cobalt44.nvim',
  dependencies = { 'tjdevries/colorbuddy.nvim', tag = 'v1.0.0' },
  priority = 1000,
  init = function()
    require('colorbuddy').colorscheme 'cobalt44'
  end,
}