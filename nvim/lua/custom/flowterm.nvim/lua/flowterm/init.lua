local M = {
  state = {
    floating = {
      buf = -1,
      win = -1,
    },
  },
}

local function create_floating_window(opts)
  opts = opts or {}

  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil

  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  local ui = require 'lib.ui'

  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = ui.border_chars_outer_thin,
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

-- @param[opt=nil] type the type of buffer, currently only supports terminal
M.toggle_floating_win = function(type)
  if not vim.api.nvim_win_is_valid(M.state.floating.win) then
    M.state.floating = create_floating_window { buf = M.state.floating.buf }

    if type == 'terminal' and vim.bo[M.state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(M.state.floating.win)
  end
end

return M
