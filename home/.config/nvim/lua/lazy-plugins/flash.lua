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
  end,
}
