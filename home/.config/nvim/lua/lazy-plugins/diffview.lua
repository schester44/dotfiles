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
      enhanced_diff_hl = true,
    }
  end,
}
