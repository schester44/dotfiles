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
vim.api.nvim_create_user_command('Todos', function()
  vim.fn.setqflist {}
  local ok, _ = pcall(function()
    vim.cmd 'vimgrep /- \\[ \\]/ **/*.md'
  end)
  if ok then
    vim.cmd 'copen'
  else
    vim.notify('No unchecked markdown checkboxes found.', vim.log.levels.INFO)
  end
end, {})
