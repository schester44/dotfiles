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

-- :Zcd  - hybrid cd: literal path if it exists, otherwise zoxide query
-- :Zlcd - same, but window-local (:lcd)
-- Lowercase :zcd / :zlcd work via command-line abbreviations.
local function zoxide_resolve(query)
  local expanded = vim.fn.expand(query)
  if vim.fn.isdirectory(expanded) == 1 then
    return expanded
  end
  local out = vim.fn.systemlist { 'zoxide', 'query', '--', unpack(vim.split(query, '%s+')) }
  if vim.v.shell_error ~= 0 or #out == 0 then
    return nil
  end
  return out[1]
end

local function make_zcd(cd_cmd)
  return function(opts)
    local dir
    if opts.args == '' then
      dir = vim.uv.os_homedir()
    else
      dir = zoxide_resolve(opts.args)
    end
    if not dir then
      vim.notify('zcd: no match for ' .. opts.args, vim.log.levels.ERROR)
      return
    end
    vim.cmd[cd_cmd](vim.fn.fnameescape(dir))
    vim.fn.system { 'zoxide', 'add', '--', dir }
    vim.notify(dir)
  end
end

local function zcd_complete(arglead)
  local dirs = vim.fn.getcompletion(arglead, 'dir')
  local zout = vim.fn.systemlist { 'zoxide', 'query', '--list', '--', arglead }
  if vim.v.shell_error == 0 then
    vim.list_extend(dirs, zout)
  end
  return dirs
end

vim.api.nvim_create_user_command('Zcd', make_zcd 'cd', { nargs = '*', complete = zcd_complete })
vim.api.nvim_create_user_command('Zlcd', make_zcd 'lcd', { nargs = '*', complete = zcd_complete })

vim.cmd [[
  cnoreabbrev <expr> zcd  (getcmdtype() ==# ':' && getcmdline() ==# 'zcd')  ? 'Zcd'  : 'zcd'
  cnoreabbrev <expr> zlcd (getcmdtype() ==# ':' && getcmdline() ==# 'zlcd') ? 'Zlcd' : 'zlcd'
]]
