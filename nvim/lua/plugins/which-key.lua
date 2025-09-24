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
    preset = 'helix',
    show_help = false,
    icons = {
      mappings = vim.g.have_nerd_font,
    },
    spec = {
      {
        '<leader>c',
        group = 'Code',
        mode = { 'n', 'x' },
        icon = { icon = icons.code, color = 'yellow' },
      },
      { '<leader>a', group = 'Avante', icon = { icon = icons.copilot, color = 'yellow' } },
      { '<leader>g', group = 'Git', icon = { icon = icons.git, color = 'yellow' } },
      { '<leader>r', group = 'Requests', icon = { icon = icons.search, color = 'red' } },
      { '<leader>l', group = 'LSP', icon = { icon = icons.code, color = 'yellow' } },
      { '<leader>s', group = 'Search', icon = { icon = icons.search, color = 'yellow' } },
      { '<leader>f', group = 'File', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>b', group = 'Buffer', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>p', group = 'Profiler', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>T', group = 'Toggle', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>t', group = 'Test', icon = { icon = icons.test, color = 'yellow' } },
      { '<leader>o', group = 'Obsidian', icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>n', group = 'Noice', icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>x', group = 'Trouble', icon = { icon = icons.diagnostics, color = 'yellow' } },
      { '<leader>d', group = 'DAP', icon = { icon = icons.diagnostics, color = 'yellow' } },
    },
  },
}
