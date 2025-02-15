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
