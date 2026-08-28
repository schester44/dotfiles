local paths = require 'lib.paths'

-- :Todo        - checkboxes in current file
-- :Todo all    - checkboxes across vault
-- :Todo <file> - checkboxes in specified file
vim.api.nvim_create_user_command('Todo', function(opts)
  local arg = opts.args
  local target

  if arg == '' then
    target = vim.fn.expand '%:p'
  elseif arg == 'all' then
    target = vim.fn.expand(paths.vault)
  else
    target = vim.fn.expand(arg)
  end

  local cmd = { 'rg', '--no-ignore', '--vimgrep', '--', '- \\[ \\]', target }
  local output = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 or #output == 0 then
    vim.fn.setqflist {}
    vim.notify('No unchecked checkboxes found.', vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, ' ', {
    title = 'Todos: ' .. (arg == '' and vim.fn.expand '%:t' or arg == 'all' and 'vault' or arg),
    lines = output,
  })
  vim.cmd 'copen'
end, {
  nargs = '?',
  complete = function(_, cmdline, _)
    local args = vim.split(cmdline, '%s+')
    if #args <= 2 then
      return { 'all' }
    end
    return {}
  end,
})

vim.keymap.set('n', '<leader>td', '<cmd>Todo<CR>', { desc = 'Todos' })
vim.keymap.set('n', '<leader>tD', '<cmd>Todo all<CR>', { desc = 'All Todos' })
