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
    sort = { 'alphanum' },
    icons = {
      mappings = vim.g.have_nerd_font,
    },
    spec = {
      { '<leader>b', group = 'Buffer',         icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>d', group = 'Trouble',        icon = { icon = icons.diagnostics, color = 'yellow' } },
      { '<leader>f', group = 'File',           icon = { icon = icons.file, color = 'yellow' } },
      { '<leader>g', group = 'Git',            icon = { icon = icons.git, color = 'yellow' } },
      { '<leader>h', group = 'Hunk',           icon = { icon = icons.git, color = 'yellow' } },
      { '<leader>l', group = 'LSP',            icon = { icon = icons.code, color = 'yellow' } },
      { '<leader>o', group = 'Obsidian',       icon = { icon = icons.note, color = 'yellow' } },
      { '<leader>r', group = 'Requests',       icon = { icon = icons.search, color = 'red' } },
      { '<leader>s', group = 'Search',         icon = { icon = icons.search, color = 'yellow' } },
      { '<leader>t', group = 'Tabs|Toggle',    icon = { icon = icons.file, color = 'yellow' } },
      { 'gO',        desc = 'Document Symbols' },

      -- remove default tab mappings
      { 'gt',        hidden = true },
      { 'gT',        hidden = true },

      { 'gr',        group = 'LSP',            mode = { 'n', 'x' },                                  icon = { icon = icons.code, color = 'cyan' } },
      { 'gra',       desc = 'Code Action',     mode = { 'n', 'x' } },
      { 'gri',       desc = 'Implementation' },
      { 'grn',       desc = 'Rename' },
      { 'grr',       desc = 'References' },
      { 'grt',       desc = 'Type Definition' },
      { 'grx',       desc = 'Codelens' },
    },
  },
}
