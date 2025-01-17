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
