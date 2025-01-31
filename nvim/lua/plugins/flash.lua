return {
  'folke/flash.nvim',
  vent = 'VeryLazy',

  keys = {
    {
      'gw',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      '<c-s>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
  },
  config = function()
    require('flash').setup {
      ---@type Flash.Config
      label = { uppercase = false },
      modes = { char = {
        highlight = { backdrop = false },
      } },
    }

    local palette = require 'cobalt44.palette'
    vim.api.nvim_set_hl(0, 'FlashMatch', { bg = palette.blue, fg = palette.cobalt_bg_dark })
    vim.api.nvim_set_hl(0, 'FlashCurrent', { bg = palette.blue, fg = palette.cobalt_bg_dark })
    vim.api.nvim_set_hl(0, 'FlashLabel', { bg = palette.yellow, fg = palette.cobalt_bg_dark })
  end,
}
