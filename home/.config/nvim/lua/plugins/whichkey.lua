local plugins = require 'lib.plugins'

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

plugins.add {
  src = 'folke/which-key.nvim',
  opts = {
    preset = 'helix',
    show_help = false,
    sort = { 'alphanum' },
    icons = {
      mappings = vim.g.have_nerd_font,
    },
    spec = {
      { '<leader>a', group = 'Avante', icon = { icon = icons.copilot, color = 'yellow' } },
      { '<leader>b', group = 'Buffer', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>c', group = 'Code', mode = { 'n', 'x' }, icon = { icon = icons.code, color = 'yellow' } },
      { '<leader>d', group = 'DAP', icon = { icon = icons.diagnostics, color = 'yellow' } },
      { '<leader>d', group = 'Trouble', icon = { icon = icons.diagnostics, color = 'yellow' } },
      { '<leader>f', group = 'File', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>g', group = 'Git', icon = { icon = icons.git, color = 'yellow' } },
      { '<leader>h', group = 'Hunk', icon = { icon = icons.git, color = 'yellow' } },
      { '<leader>l', group = 'LSP', icon = { icon = icons.code, color = 'yellow' } },
      { '<leader>n', group = 'Noice', icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>o', group = 'Obsidian', icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>p', group = 'Profiler', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>r', group = 'Requests', icon = { icon = icons.search, color = 'red' } },
      { '<leader>s', group = 'Search', icon = { icon = icons.search, color = 'yellow' } },
      { '<leader>t', group = 'Tabs', icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>x', group = 'Toggle', icon = { icon = icons.test, color = 'yellow' } },
      { 'gO', desc = 'Document Symbols' },

      -- remove default tab mappings
      { 'gt', hidden = true },
      { 'gT', hidden = true },

      { 'gr', group = 'LSP', mode = { 'n', 'x' }, icon = { icon = icons.code, color = 'cyan' } },
      { 'gra', desc = 'Code Action', mode = { 'n', 'x' } },
      { 'gri', desc = 'Implementation' },
      { 'grn', desc = 'Rename' },
      { 'grr', desc = 'References' },
      { 'grt', desc = 'Type Definition' },
      { 'grx', desc = 'Codelens' },
    },
  },
}
