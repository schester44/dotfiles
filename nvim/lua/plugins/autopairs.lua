return {
  'windwp/nvim-autopairs',
  cond = not vim.g.vscode,
  event = 'InsertEnter',
  opts = {},
}
