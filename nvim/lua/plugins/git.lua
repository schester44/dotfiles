return {
  { 'tpope/vim-fugitive', cond = not vim.g.vscode },
  { 'tpope/vim-rhubarb', cond = not vim.g.vscode },
  { 'sindrets/diffview.nvim', cond = not vim.g.vscode },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {},
    cond = not vim.g.vscode,
  },
}
