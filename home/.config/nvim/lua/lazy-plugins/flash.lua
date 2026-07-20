return {
  'folke/flash.nvim',
  event = 'VeryLazy',

  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Flash Remote',
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
      highlight = { backdrop = true },
      label = { uppercase = false },
      modes = { char = {
        highlight = { backdrop = false },
      } },
    }

    local palette = require 'grapelean.palette'
    vim.api.nvim_set_hl(0, 'FlashBackdrop', { italic = true })
    vim.api.nvim_set_hl(0, 'FlashMatch', { underline = true, bold = true, fg = palette.pink })
    vim.api.nvim_set_hl(0, 'FlashCurrent', { underline = true, bold = true, fg = palette.pink_light })
    vim.api.nvim_set_hl(0, 'FlashLabel', { bg = palette.yellow, fg = palette.bg_dark })
  end,
}
