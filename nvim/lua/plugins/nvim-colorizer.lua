-- test: #f299ee

return {
  'NvChad/nvim-colorizer.lua',
  cond = not vim.g.vscode,
  event = 'BufReadPre',
  opts = {
    user_default_options = {
      names = false,
      rgb_fn = true,
    },
  },
}
