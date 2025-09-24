local ffi = require 'lib.statuscolumn.ffidef'
local C = ffi.C
local error = ffi.new 'Error'
local ui = require 'lib.ui'

local statuscolumn = {}

local theme_palette = require 'cobalt44.palette'

local user_config = {
  colors = {
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
    theme_palette.dim_blue,
  },
}

-- generate hlgroups
for i, color in ipairs(user_config.colors) do
  if i == 1 then
    vim.api.nvim_set_hl(0, 'FoldLevel_' .. i, { fg = color, bold = true })
  else
    vim.api.nvim_set_hl(0, 'FoldLevel_' .. i, { fg = color })
  end
end

vim.api.nvim_set_hl(0, 'FoldClosed', { fg = theme_palette.purple })

statuscolumn.number = function()
  local is_cmd_open = vim.fn.mode() == 'c'

  if vim.v.relnum == 0 then
    return ui.hl_str('CursorLineNr', vim.v.lnum)
  end

  return is_cmd_open and vim.v.lnum or vim.v.relnum
end

vim.o.foldnestmax = #user_config.colors

statuscolumn.render = function()
  local text = ''

  text = table.concat {
    '',
    '%s',
    statuscolumn.number(),
    ' ',
    '%=',
  }

  return text
end

statuscolumn.border = function()
  return ui.hl_str('FoldColumn', '│')
end

statuscolumn.folds = function()
  local line = vim.v.lnum
  local fold = vim.fn.foldlevel(line)
  local is_folded = vim.fn.foldclosed(line) ~= -1
  local is_fold_start = vim.fn.foldlevel(line) > vim.fn.foldlevel(line - 1)

  local endLn = vim.fn.foldclosedend(line)

  if fold > 0 and is_fold_start then
    if is_folded then
      local count = endLn - line
      return ui.hl_str('FoldClosed', ' ' .. count)
    end
  end

  return '  '
end

statuscolumn.pretty_folds = function()
  local win = vim.g.statusline_winid
  local wp = C.find_window_by_handle(win, error)
  local opts = { win = win }
  local culopt = vim.api.nvim_get_option_value('culopt', opts)

  -- some separators for maybe-use
  --┃, ┆, ┇, ┊, ┋, ╎, ╏, │
  local args = {
    wp = wp,
    relnum = vim.v.relnum,
    virtnum = vim.v.virtnum,
    lnum = vim.v.lnum,
    cul = vim.api.nvim_get_option_value('cul', opts) and (culopt:find 'nu' or culopt:find 'bo'),
    fold = {
      width = C.compute_foldcolumn(wp, 0),
      open = '╭',
      close = '%=',
      sep = '│',
      eofold = '╰',
    },
  }

  local width = args.fold.width

  -- if no width for foldcolumn, theres nothing to show
  if width == 0 then
    return ''
  end

  local foldinfo = C.fold_info(args.wp, args.lnum)
  local after_foldinfo = C.fold_info(args.wp, args.lnum + 1)
  local string = args.cul and args.relnum == 0 and '%#CursorLineFold#' or '%#FoldColumn#'

  local level = foldinfo.level

  local after_level = after_foldinfo.level

  if level == 0 then
    return string .. (' '):rep(width) .. '%*'
  end

  string = '%#FoldLevel_' .. level .. '#'

  local foldclosed = foldinfo.lines > 0
  local first_level = level - width - (foldclosed and 1 or 0) + 1
  if first_level < 1 then
    first_level = 1
  end

  local after_foldclosed = after_foldinfo.lines > 0
  local after_first_level = after_level - width - (after_foldclosed and 1 or 0) + 1
  if after_first_level < 1 then
    after_first_level = 1
  end

  local should_be_sep = after_level > level
  local range = level < width and level or width
  for col = 1, range do
    local is_after_open = after_foldinfo.start == args.lnum + 1 and after_first_level + col > after_foldinfo.llevel
    if args.virtnum ~= 0 then
      string = string .. args.fold.sep
    elseif foldclosed and (col == level or col == width) then
      string = string .. '%#FoldClosed#' .. args.fold.close
    elseif foldinfo.start == args.lnum and first_level + col > foldinfo.llevel then
      string = string .. args.fold.open
    elseif (level > after_level or is_after_open or after_foldclosed) and not should_be_sep then
      string = string .. args.fold.eofold
    else
      string = string .. args.fold.sep
    end
  end
  if range < width then
    string = string .. (' '):rep(width - range)
  end

  return string .. '%*'
end

return statuscolumn
