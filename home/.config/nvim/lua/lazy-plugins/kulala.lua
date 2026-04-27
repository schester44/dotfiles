return {
  'mistweaverco/kulala.nvim',
  keys = {},
  ft = { 'http', 'rest' },
  opts = {
    lsp = {
      enable = true,
      filetypes = { 'http', 'rest' },
      formatter = {
        split_params = 4,
        sort = {
          metadata = true,
          variables = true,
          commands = false,
          json = true,
        },
      },
    },
    global_keymaps = false,
    kulala_keymaps_prefix = '',
  },
}
