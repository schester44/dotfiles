return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    require('noice').setup {
      cmdline = {
        view = 'cmdline_popup', -- Default style
        wrap = true,
        format = {
          cmdline = { icon = '❯' },
        },
      },
      notify = {
        wrap = true,
      },
    }
  end,
}
