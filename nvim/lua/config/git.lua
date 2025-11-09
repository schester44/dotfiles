local function git_browse()
  local filepath = vim.fn.expand '%'
  if filepath == '' then
    return
  end

  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  local relpath = filepath:gsub(git_root .. '/', '')

  local remote_url = vim.fn.systemlist('git config --get remote.origin.url')[1]
  if not remote_url or remote_url == '' then
    print 'No remote URL found'
    return
  end

  remote_url = remote_url:gsub('git@([^:]+):', 'https://%1/'):gsub('%.git$', '')

  local ref = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]
  if ref == 'HEAD' then
    ref = vim.fn.systemlist('git rev-parse HEAD')[1]
  end

  local url = string.format('%s/blob/%s/%s', remote_url, ref, relpath)

  local line = vim.fn.line '.'
  url = url .. '#L' .. line

  local open_cmd
  if vim.fn.has 'macunix' == 1 then
    open_cmd = 'open'
  elseif vim.fn.has 'unix' == 1 then
    open_cmd = 'xdg-open'
  elseif vim.fn.has 'win32' == 1 then
    open_cmd = 'powershell /c start'
  end

  vim.fn.jobstart({ open_cmd, url }, { detach = true })
end

vim.keymap.set({ 'n', 'v' }, '<leader>go', function()
  git_browse()
end, { desc = 'Open GitHub at current line' })
