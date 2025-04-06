return {
  'sindrets/diffview.nvim',
  config = function()
    vim.opt.diffopt = {
      'internal',
      'filler',
      'closeoff',
      'context:12',
      'algorithm:histogram',
      'linematch:200',
      'indent-heuristic',
    }

    require('diffview').setup {
      enhance_diff_hl = true, -- Adds highlights for diff hunks
      use_icons = true, -- Requires nvim-web-devicons
      view = {
        default = {
          layout = 'diff2_horizontal', -- Use the diff2 layout by default
        },
      },
    }
  end,
}
