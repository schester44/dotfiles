return {
  {
    'fredrikaverpil/pr.nvim',
    lazy = true,
    version = '*',
    ---@type PR.Config
    opts = {},
    keys = {
      {
        '<leader>gv',
        function()
          require('pr').view()
        end,
        desc = 'View PR in browser',
      },
    },
    cmd = { 'PRView' },
  },
}
