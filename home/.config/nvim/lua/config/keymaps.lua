local set = vim.keymap.set

set('n', 'gt', '<Nop>')
set('n', 'gT', '<Nop>')

set('i', '<C-BS>', '<C-w>', { desc = 'Delete word backward' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
set('t', '<C-h>', '<C-\\><C-N><C-w>h', { desc = 'Move focus to the left window' })
set('t', '<C-l>', '<C-\\><C-N><C-w>j', { desc = 'Move focus to the right window' })
set('t', '<C-j>', '<C-\\><C-N><C-w>j', { desc = 'Move focus to the lower window' })
set('t', '<C-k>', '<C-\\><C-N><C-w>l', { desc = 'Move focus to the upper window' })
-- Diagnostic keymaps
-- For other diagnostic commands, see trouble.lua
set('n', '<leader>dm', function()
  local float_bufnr, win = vim.diagnostic.open_float { border = 'rounded' }

  if win then
    local source_buf = vim.api.nvim_get_current_buf()

    local function cleanup()
      pcall(vim.keymap.del, 'n', '<CR>', { buffer = source_buf })
    end

    vim.keymap.set('n', '<CR>', function()
      cleanup()
      vim.api.nvim_set_current_win(win)
    end, { buffer = source_buf, desc = 'Focus diagnostic float' })

    vim.api.nvim_create_autocmd('WinClosed', {
      pattern = tostring(win),
      once = true,
      callback = cleanup,
    })
  end
end, { desc = 'Open diagnostic message' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

set('n', 'U', '<C-r>', { desc = 'Redo' })

set('v', 'p', '"_dP', { desc = 'Paste without overwriting register' })

set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

set({ 'n', 'v' }, '<leader>aa', function()
  require('lib.pi-edit').edit_selection()
end, { desc = 'AI Inline' })

set('v', '<leader>ae', function()
  require('lib.pi-edit').send_to_pane()
end, { desc = 'AI Pane Edit' })

set('n', '<leader>am', function()
  require('lib.pi-edit').select_model()
end, { desc = 'Pi Select Model' })

set('n', 'grv', function()
  vim.cmd 'vsplit'
  vim.lsp.buf.definition()
end, { desc = 'VSplit Definition' })

-- Preserve window layouts when closing a buffer
vim.keymap.set('n', '<leader>bd', function()
  -- Temporarily disable winfixbuf if set, so mini.bufremove can switch buffers
  local win = vim.api.nvim_get_current_win()
  local winfixbuf = vim.wo[win].winfixbuf
  if winfixbuf then
    vim.wo[win].winfixbuf = false
  end

  MiniBufremove.delete(0)

  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ''
  end, vim.api.nvim_list_bufs())

  if #buffers == 0 then
    -- close extra splits and open dashboard
    vim.cmd 'only'
    require('mini.starter').open()

    -- Find and delete NoName buffers after mini.starter is open
    vim.defer_fn(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name == '' and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
          vim.api.nvim_buf_delete(buf, { force = false })
        end
      end
    end, 300)
  end
end, { desc = 'Delete Buffer' })

set('n', '<leader>bo', function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      MiniBufremove.delete(buf)
    end
  end
end, { desc = 'Delete Other Buffers' })

set('n', '<leader>ba', function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      MiniBufremove.delete(buf)
    end
  end
  vim.cmd 'only'
  require('mini.starter').open()
  vim.defer_fn(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name == '' and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
        vim.api.nvim_buf_delete(buf, { force = false })
      end
    end
  end, 300)
end, { desc = 'Delete All Buffers' })

set('n', '<leader>w', '<cmd>w<CR>', { desc = 'which_key_ignore' })
set('n', '<leader>q', '<cmd>q<CR>', { desc = 'which_key_ignore' })
set('n', '<leader>Q', '<cmd>qa<CR>', { desc = 'which_key_ignore' })

set('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Previous Tab' })
set('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next Tab' })

set('n', '<leader>fcp', '<cmd>let @+=expand("%:p")<CR>', { desc = 'Copy file path to clipboard' })
set('n', '<leader>fcl', function()
  local path = vim.fn.expand '%:p'
  local line = vim.fn.line '.'
  vim.fn.setreg('+', path .. ':' .. line)
  vim.notify('Copied: ' .. path .. ':' .. line)
end, { desc = 'Copy file path with line number' })
set('v', '<leader>fcl', function()
  local path = vim.fn.expand '%:p'
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local result = path .. ':' .. start_line .. '-' .. end_line
  vim.fn.setreg('+', result)
  vim.notify('Copied: ' .. result)
end, { desc = 'Copy file path with line range' })
set('n', '<leader>fof', '<cmd>silent !open %:p:h<CR>', { desc = 'Open file in Finder' })

-- Yank to system clipboard
set({ 'n', 'v' }, 'gy', '"+y', { desc = 'Yank to system clipboard' })
set({ 'n', 'v' }, 'gY', '"+Y', { desc = 'Yank line to system clipboard' })

-- Remap g< (ui2 pager: show recent messages) to <leader>xm
-- g< is taken by vim-swap (<Plug>(swap-prev))
set('n', '<leader>dp', 'g<', { desc = 'Show messages (ui2 pager)' })

set('n', '<leader>th', function()
  local current_state = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not current_state)
  vim.notify('Inlay hints ' .. (not current_state and 'enabled' or 'disabled'))
end, { desc = 'Toggle inlay hints' })
