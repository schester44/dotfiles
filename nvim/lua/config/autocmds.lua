local create = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

create('BufWritePre', {
  desc = 'Fix all eslint issues on save',
  pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
  command = 'silent! EslintFixAll',
  group = augroup('MyAutocmdsJavaScripFormatting', {}),
})

create('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

create('CmdlineEnter', {
  desc = 'Show absolute numbers when entering command-line mode',
  pattern = ':',
  callback = function()
    vim.o.relativenumber = false
  end,
})

create('CmdlineLeave', {
  desc = 'Show relative numbers when leaving command-line mode',
  pattern = ':',
  callback = function()
    vim.o.relativenumber = true
  end,
})
