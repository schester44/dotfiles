return {
  {
    'github.nvim',
    dev = true,
    config = function()
      require('github').setup()
    end,
  },
}
