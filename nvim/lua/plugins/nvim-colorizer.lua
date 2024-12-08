-- test: #f299ee

return {
  'NvChad/nvim-colorizer.lua',
  event = 'BufReadPre',
  opts = {
    user_default_options = {
      names = false,
      rgb_fn = true,
    },
  },
}
