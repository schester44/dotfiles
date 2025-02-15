local ui = require 'lib.ui'
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
      cmdline = {
        view = 'cmdline_popup',
        wrap = true,
        format = {
          cmdline = { icon = '' },
          lua = { icon = '' },
          search_down = { icon = '' },
          search_up = { icon = '' },
        },
      },
      notify = {
        wrap = true,
      },
      views = {
        cmdline_popup = {
          border = {
            style = ui.border_chars_outer_thin,
            padding = { 0, 0 },
          },
        },
      },
    }
  end,
}
