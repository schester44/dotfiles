local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local view_group = augroup('auto_view', { clear = true })

-- The following two autocmds are taken from AstroVim.
-- They are used to save and load the view of a file when it is opened and closed (folds, etc).
autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
  desc = 'Save view with mkview for real files',
  group = view_group,
  callback = function(args)
    if vim.b[args.buf].view_activated then
      vim.cmd.mkview { mods = { emsg_silent = true } }
    end
  end,
})

autocmd('BufWinEnter', {
  desc = 'Try to load file view if available and enable view saving for real files',
  group = view_group,
  callback = function(args)
    if not vim.b[args.buf].view_activated then
      local filetype = vim.api.nvim_get_option_value('filetype', { buf = args.buf })
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = args.buf })
      local ignore_filetypes = { 'gitcommit', 'gitrebase', 'svg', 'hgcommit' }
      if buftype == '' and filetype and filetype ~= '' and not vim.tbl_contains(ignore_filetypes, filetype) then
        vim.b[args.buf].view_activated = true
        vim.cmd.loadview { mods = { emsg_silent = true } }
      end
    end
  end,
})

autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

autocmd('CmdlineEnter', {
  desc = 'Show absolute numbers when entering command-line mode',
  pattern = ':',
  callback = function()
    vim.o.relativenumber = false
  end,
})

autocmd('CmdlineLeave', {
  desc = 'Show relative numbers when leaving command-line mode',
  pattern = ':',
  callback = function()
    vim.o.relativenumber = true
  end,
})

autocmd({ 'BufLeave', 'QuitPre' }, {
  desc = 'Autosave vault notes',
  pattern = '*.md',
  callback = function()
    local filepath = vim.fn.expand '%:p'
    if filepath:find(vim.fn.expand '~/vaults/') then
      vim.cmd 'silent! write'
    end
  end,
})
