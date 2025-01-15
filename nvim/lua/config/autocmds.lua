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

local target_directory = '/Users/schester/work/risk-management'
local script_path = target_directory .. '/setup-scripts/sync-environments.sh'

if vim.fn.getcwd() == target_directory then
  vim.api.nvim_create_user_command('EnvSync', function()
    print(vim.fn.system(script_path))
  end, { desc = 'Sync infisical environment' })

  vim.keymap.set('n', '<leader>es', '<CMD>EnvSync<CR>', { desc = '[E]nvironment [S]ync' })
end
