local icons = {
  code = '',
  diagnostics = '',
  file = '',
  git = '󰊢',
  image = '',
  note = '',
  search = '',
  test = '󰱑',
  text = '󰊄',
  toggle = '',
  copilot = '',
}

return {
  'folke/which-key.nvim',
  cond = not vim.g.vscode,
  event = 'VimEnter',
  opts = {
    icons = {
      mappings = vim.g.have_nerd_font,
    },
    spec = {
      { '<leader>i', desc = 'Paste image from clipboard', icon = { icon = icons.image, color = 'blue' } },
      { '<leader>p', desc = 'Paste from system clipboard', icon = { icon = icons.text, color = 'blue' } },
      { '<leader>Y', desc = 'Copy to end of line to system clipboard', icon = { icon = icons.text, color = 'blue' } },
      { '<leader>y', desc = 'Copy to system clipboard', icon = { icon = icons.text, color = 'blue' } },
      { '<leader>q', desc = 'Quit', icon = { icon = icons.file, color = 'red' } },
      { '<leader>w', desc = 'Write', icon = { icon = icons.file, color = 'red' } },

      { '<leader><tab>', desc = 'Goto last buffer', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>,', desc = 'Open Buffers', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader><space>', desc = 'Find Files', icon = { icon = icons.file, color = 'yellow' } },

      {
        '<leader>c',
        group = 'Code',
        mode = { 'n', 'x' },
        icon = { icon = icons.code, color = 'yellow' },
      },
      { '<leader>a', group = 'Avante', icon = { icon = icons.copilot, color = 'yellow' } },
      { '<leader>g', group = 'Git', icon = { icon = icons.git, color = 'yellow' } },
      { '<leader>l', group = 'LSP', icon = { icon = icons.code, color = 'yellow' } },
      { '<leader>s', group = 'Search', icon = { icon = icons.search, color = 'yellow' } },
      { '<leader>f', group = 'File', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>b', group = 'Buffer', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>T', group = 'Toggle', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>t', group = 'Test', icon = { icon = icons.test, color = 'yellow' } },
      { '<leader>o', group = 'Obsidian', icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>n', group = 'Noice', icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>x', group = 'Trouble', icon = { icon = icons.diagnostics, color = 'yellow' } },
      { '<leader>d', group = 'DAP', icon = { icon = icons.diagnostics, color = 'yellow' } },
    },
  },
}
