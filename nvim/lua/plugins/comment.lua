return {
  {
    -- does stuff for commenting, eg gcc to comment out a line
    'numToStr/Comment.nvim',
    cond = not vim.g.vscode,
    opts = {},
  },
}
