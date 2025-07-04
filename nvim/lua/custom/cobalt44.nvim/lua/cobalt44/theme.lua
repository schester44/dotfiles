local colors = require('cobalt44.utils').colors
local styles = require('cobalt44.utils').styles
local Group = require('cobalt44.utils').Group

Group.new('MiniStarterHeader', colors.light_blue_green, nil, nil)

Group.new('ColorColumn', nil, colors.cursor_line, nil)
Group.new('CommandMode', colors.black, colors.darker_blue, nil)
Group.new('Conceal', colors.dark_grey, nil, nil)
Group.new('CurSearch', colors.cobalt_bg_dark, colors.light_pink, styles.NONE)
Group.new('Cursor', colors.yellow, colors.cobalt_bg, nil)
Group.new('CursorColumn', nil, colors.cursor_hover, nil)
Group.new('CursorIM', colors.yellow, colors.cobalt_bg, nil)
Group.new('CursorLine', nil, colors.cobalt_bg, nil)
Group.new('CursorLineNr', colors.yellow, nil, styles.bold)
Group.new('DiffAdd', colors.green, nil, nil)
Group.new('DiffChange', colors.green, nil, nil)
Group.new('DiffDelete', colors.red, nil, nil)
Group.new('DiffText', colors.white, nil, nil)
Group.new('Directory', colors.blue, nil, nil)
Group.new('ErrorMsg', colors.red:light(), nil, nil)
Group.new('FloatBorder', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)
Group.new('FloatTitle', colors.light_blue, colors.cobalt_bg, nil)
Group.new('FoldColumn', colors.cobalt_bg_light, nil, nil)
-- Folded text/backgroun
Group.new('Folded', colors.purple, colors.cobalt_bg, styles.italic)
Group.new('MoreMsg', colors.light_yellow, nil, nil)
Group.new('FoldedText', colors.dirty_blue, nil, nil)

Group.new('IncSearch', colors.black, colors.yellow, styles.NONE)
Group.new('InsertMode', colors.black, colors.dirty_blue, nil)
Group.new('LineNr', colors.dim_blue, colors.cobalt_bg, styles.NONE)
Group.new('MatchParen', colors.white, colors.dark_purple, styles.bold)
Group.new('MatchWord', colors.white, colors.dark_purple, styles.bold)
Group.new('ModeMsg', colors.white, nil, styles.bold)
Group.new('NonText', colors.dark_grey, nil, nil)
-- Controls the background color of the editor
Group.new('Normal', colors.white, colors.cobalt_bg, nil)

-- Controls the background color of autocomplete popup and oil.nvim, whichkey, floating windows, etc
Group.new('NormalFloat', colors.white, colors.cobalt_bg_dark, nil)
Group.new('NormalMode', colors.black, colors.yellow, nil)
Group.new('NormalNC', colors.white, colors.cobalt_bg, nil)

Group.new('LazyGitFloat', nil, colors.cobalt_bg_dark, nil)
Group.new('LazyGitBorder', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)

Group.new('CmpNormal', colors.white, colors.cobalt_bg_dark, nil)
-- Controls the color of the selected item

Group.new('CmpCursorLine', colors.light_yellow, colors.cobalt_bg, nil)
Group.new('CmpDocNormal', colors.white, colors.cobalt_bg_dark, nil)

Group.new('PMenu', colors.white, colors.cobalt_bg_dark, nil)
Group.new('PMenuSBar', nil, colors.cobalt_bg, nil)

Group.new('PmenuSel', colors.light_yellow, colors.cobalt_bg, nil)
Group.new('PMenuThumb', nil, colors.cobalt_bg_dark, nil)

Group.new('Question', colors.green, nil, nil)
Group.new('QuickFixLine', nil, colors.cursor_hover, nil)
Group.new('ReplacelMode', colors.black, colors.dark_pink, nil)
Group.new('Search', colors.cobalt_bg_dark, colors.blue, styles.NONE)
Group.new('SignColumn', colors.cobalt_bg, nil, nil)
Group.new('SpecialKey', colors.light_blue, colors.cobalt_bg, nil)
Group.new('SpellBad', colors.red, nil, styles.underline)
Group.new('SpellCap', nil, colors.darkest_blue, styles.underline)
Group.new('SpellLocal', nil, colors.darkest_green, styles.underline)
Group.new('SpellRare', nil, colors.aubergine, styles.underline)
Group.new('StatusLineNC', colors.white, colors.cursor_line, nil)
Group.new('StatusLine', colors.yellow, colors.cursor_line, nil)
Group.new('TabLine', colors.yellow, colors.cursor_hover, nil)
Group.new('TabLineFill', colors.light_grey, nil, nil)
Group.new('TabLineSel', colors.white, colors.cobalt_bg, styles.bold)
Group.new('Title', colors.dirty_green, nil, styles.bold)
Group.new('VertSplit', colors.grey, nil, nil)
Group.new('Visual', nil, colors.darker_blue, nil)
Group.new('VisualMode', colors.black, colors.dirty_pink, nil)
Group.new('VisualNOS', nil, colors.darkest_blue, nil)
Group.new('WarningMsg', colors.light_yellow, nil, nil)
Group.new('Warnings', colors.light_yellow, nil, nil)
Group.new('Whitespace', colors.dark_grey, nil, nil)
Group.new('WildMenu', colors.blue, colors.yellow, nil)
Group.new('WinBar', colors.yellow, nil, nil)
Group.new('healthError', colors.red:light(), nil, nil)
Group.new('healthSuccess', colors.green, nil, nil)
Group.new('healthWarning', colors.light_yellow, nil, nil)
Group.new('qfLineNr', colors.light_grey, colors.cobalt_bg, nil)

Group.new('WinSeparator', colors.cobalt_bg_light, nil, nil)

-- Noice
Group.new('NoiceCmdlinePopup', nil, colors.cobalt_bg_dark, nil)

Group.new('NoiceCmdlineIcon', colors.purple, nil, nil)
Group.new('NoiceCmdlinePopupTitleSearch', colors.light_yellow, colors.cobalt_bg, nil)
Group.new('NoiceCmdlinePopupTitleLua', colors.light_blue, colors.cobalt_bg, nil)
Group.new('NoiceCmdlinePopupTitleInput', colors.light_blue, colors.cobalt_bg, nil)
Group.new('NoiceCmdlinePopupTitleHelp', colors.purple, colors.cobalt_bg, nil)

Group.new('NoiceCmdlinePopupBorderSearch', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)
Group.new('NoiceCmdlinePopupBorderLua', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)
Group.new('NoiceCmdlinePopupBorderCmdline', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)
Group.new('NoiceCmdlinePopupBorderHelp', colors.cobalt_bg_dark, colors.cobalt_bg_dark, nil)

Group.new('NotifyBackground', nil, colors.cobalt_bg, nil)

-- EasyMotion
Group.new('EasyMotionTarget', colors.yellow, colors.cobalt_bg, styles.bold)

-- CSS
Group.new('@property.css', colors.lighter_green, nil, nil)
Group.new('@function.css', colors.orange, nil, nil)
Group.new('@string.css', colors.light_yellow, nil, nil)
Group.new('@number.css', colors.light_yellow, nil, nil)
Group.new('@number.float.css', colors.light_yellow, nil, nil)
Group.new('@variable.css', colors.light_blue, nil, nil)
Group.new('@attribute.css', colors.green, nil, nil)
Group.new('@constant.css', colors.light_orange, nil, nil)
Group.new('@type.css', colors.light_orange, nil, nil)
Group.new('@keyword.operator.css', colors.green, nil, nil)
Group.new('@tag.attribute.css', colors.green, nil, nil)

Group.new('UfoFoldedBg', nil, colors.cobalt_bg_light, nil)

vim.api.nvim_set_hl(0, 'Folded', { link = 'UfoFoldedBg' })
