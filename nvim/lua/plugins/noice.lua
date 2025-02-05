return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('noice').setup {
      routes = {
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = 'written',
          },
          opts = { skip = true },
        },
      },
      presets = { lsp_doc_border = true },
      -- show macro recording message in toast
      -- routes = {
      --   {
      --     view = 'notify',
      --     filter = { event = 'msg_showmode' },
      --   },
      -- },
      cmdline = {
        view = 'cmdline_popup',
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
