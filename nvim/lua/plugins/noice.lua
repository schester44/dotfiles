return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    require('noice').setup {
      presets = { lsp_doc_border = true },
      routes = {
        {
          view = 'notify',
          filter = { event = 'msg_showmode' },
        },
      },
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
