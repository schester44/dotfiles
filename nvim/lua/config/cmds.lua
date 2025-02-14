-- EnvSync for Obie environments
local target_directory = '/Users/schester/work/risk-management'
local script_path = target_directory .. '/setup-scripts/sync-environments.sh'

if vim.fn.getcwd() == target_directory then
  vim.api.nvim_create_user_command('EnvSync', function()
    print(vim.fn.system(script_path))
  end, { desc = 'Sync infisical environment' })

  vim.keymap.set('n', '<leader>es', '<CMD>EnvSync<CR>', { desc = '[E]nvironment [S]ync' })
end

-- Find all unchecked checkboxes in markdown files
vim.api.nvim_create_user_command('Todos', function(opts)
  local path = opts.args ~= '' and vim.fn.expand '%:p' or '**/*.md' -- Use current file if an argument is provided

  vim.fn.setqflist {} -- Clear quickfix list

  local ok, _ = pcall(function()
    vim.cmd('vimgrep /- \\[ \\]/ ' .. path)
  end)

  if ok then
    vim.cmd 'copen' -- Open quickfix list
  else
    vim.notify('No unchecked markdown checkboxes found.', vim.log.levels.INFO)
  end
end, { nargs = '?' }) -- Allow optional argument
