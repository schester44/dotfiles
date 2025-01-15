local ffi = require 'lib.statuscolumn.ffidef'
local C = ffi.C
local error = ffi.new 'Error'

local statuscolumn = {}

local theme_palette = require 'cobalt44.palette'

local user_config = {
  colors = {
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
    theme_palette.cobalt_bg_light,
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

vim.api.nvim_set_hl(0, 'FoldClosed', { fg = theme_palette.blue })

statuscolumn.number = function()
  local uncolored_text = '%#LineNr#'
  local colored_text = '%#CursorLineNr#'
  return vim.v.relnum == 0 and colored_text .. vim.v.lnum or uncolored_text .. vim.v.relnum
end

vim.o.foldnestmax = #user_config.colors

statuscolumn.render = function()
  local text = ''

  local win = vim.g.statusline_winid

  if vim.api.nvim_get_current_win() ~= win then
    return text
  end

  text = table.concat {
    '%=',
    statuscolumn.number(),
    '  ',
    '%s',
    statuscolumn.pretty_folds(),
  }

  return text
end

statuscolumn.border = function()
  return '%#FoldColumn#│'
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
      sep = '╎',
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
