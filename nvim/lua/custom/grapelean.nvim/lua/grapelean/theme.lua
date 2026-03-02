local colors = require('grapelean.utils').colors
local styles = require('grapelean.utils').styles
local Group = require('grapelean.utils').Group
local palette = require 'grapelean.palette'

Group.new('MiniStarterHeader', colors.green_light, nil, nil)

Group.new('ColorColumn', nil, colors.cursor_line, nil)
Group.new('CommandMode', colors.black, colors.blue_dark, nil)
Group.new('Conceal', colors.gray_muted, nil, nil)
Group.new('CurSearch', colors.bg_dark, colors.pink_light, styles.NONE)
Group.new('Cursor', colors.yellow, colors.bg, nil)
Group.new('CursorColumn', nil, colors.cursor_hover, nil)
Group.new('CursorIM', colors.yellow, colors.bg, nil)
Group.new('CursorLine', nil, colors.bg, nil)
Group.new('CursorLineNr', colors.yellow, nil, styles.bold)
Group.new('DiffAdd', colors.green, nil, nil)
Group.new('DiffChange', colors.green, nil, nil)
Group.new('DiffDelete', colors.red, nil, nil)
Group.new('DiffText', colors.white, nil, nil)
Group.new('Directory', colors.blue, nil, nil)
Group.new('ErrorMsg', colors.red:light(), nil, nil)
Group.new('FloatBorder', colors.bg_dark, colors.bg_dark, nil)
Group.new('FloatTitle', colors.blue_light, colors.bg, nil)
Group.new('FoldColumn', colors.bg_light, nil, nil)
-- Folded text/backgroun
Group.new('Folded', colors.purple, nil, styles.italic)
Group.new('FoldedText', colors.keyword, nil, nil)
Group.new('MoreMsg', colors.yellow_light, nil, nil)

Group.new('IncSearch', colors.black, colors.yellow, styles.NONE)
Group.new('InsertMode', colors.black, colors.keyword, nil)
Group.new('LineNr', colors.gray_muted, nil, styles.NONE)
Group.new('MatchParen', colors.white, colors.purple_dark, styles.bold)
Group.new('MatchWord', colors.white, colors.purple_dark, styles.bold)
Group.new('ModeMsg', colors.white, nil, styles.bold)
Group.new('NonText', colors.gray_muted, nil, nil)
-- Controls the background color of the editor (nil for transparency)
Group.new('Normal', colors.white, nil, nil)

-- Controls the background color of autocomplete popup and oil.nvim, whichkey, floating windows, etc
Group.new('NormalFloat', colors.white, colors.bg_dark, nil)
Group.new('NormalMode', colors.black, colors.yellow, nil)
Group.new('NormalNC', colors.white, nil, nil)



Group.new('SnacksBackdrop', nil, colors.yellow, nil)

Group.new('LazyGitFloat', nil, colors.bg_dark, nil)
Group.new('LazyGitBorder', colors.bg_dark, colors.bg_dark, nil)

Group.new('CmpNormal', colors.white, colors.bg_dark, nil)
-- Controls the color of the selected item

Group.new('CmpCursorLine', colors.yellow_light, colors.bg, nil)
Group.new('CmpDocNormal', colors.white, colors.bg_dark, nil)

Group.new('PMenu', colors.white, colors.bg_dark, nil)
Group.new('PMenuSBar', nil, colors.bg, nil)

Group.new('PmenuSel', colors.yellow_light, colors.bg, nil)
Group.new('PMenuThumb', nil, colors.bg_dark, nil)

Group.new('Question', colors.green, nil, nil)
Group.new('QuickFixLine', nil, colors.cursor_hover, nil)
Group.new('ReplacelMode', colors.black, colors.pink, nil)
Group.new('Search', colors.bg_dark, colors.blue, styles.NONE)
Group.new('SignColumn', nil, nil, nil)
Group.new('SpecialKey', colors.blue_light, colors.bg, nil)
Group.new('SpellBad', colors.red, nil, styles.underline)
Group.new('SpellCap', nil, colors.purple_dark, styles.underline)
Group.new('SpellLocal', nil, colors.green_dark, styles.underline)
Group.new('SpellRare', nil, colors.red_dark, styles.underline)
Group.new('StatusLineNC', colors.white, nil, nil)
Group.new('StatusLine', colors.yellow, nil, nil)

Group.new('TabLine', colors.gray_light, colors.bg, nil)
Group.new('TabLineFill', colors.gray_light, nil, nil)
Group.new('TabLineSel', colors.yellow_light, colors.bg_light, nil)

Group.new('Title', colors.green_muted, nil, styles.bold)
Group.new('VertSplit', colors.gray, nil, nil)
Group.new('Visual', nil, colors.bg_lighter, nil)
Group.new('VisualMode', colors.black, colors.pink_muted, nil)
Group.new('VisualNOS', nil, colors.purple_dark, nil)
Group.new('WarningMsg', colors.yellow_light, nil, nil)
Group.new('Warnings', colors.yellow_light, nil, nil)
Group.new('Whitespace', colors.gray_muted, nil, nil)
Group.new('WildMenu', colors.blue, colors.yellow, nil)
Group.new('WinBar', colors.yellow, nil, nil)
Group.new('healthError', colors.red:light(), nil, nil)
Group.new('healthSuccess', colors.green, nil, nil)
Group.new('healthWarning', colors.yellow_light, nil, nil)
Group.new('qfLineNr', colors.gray_light, colors.bg, nil)

Group.new('WinSeparator', colors.bg_light, nil, nil)

-- Noice
Group.new('NoiceCmdlinePopup', nil, colors.bg_dark, nil)

Group.new('NoiceCmdlineIcon', colors.purple, nil, nil)
Group.new('NoiceCmdlinePopupTitleSearch', colors.yellow_light, colors.bg, nil)
Group.new('NoiceCmdlinePopupTitleLua', colors.blue_light, colors.bg, nil)
Group.new('NoiceCmdlinePopupTitleInput', colors.blue_light, colors.bg, nil)
Group.new('NoiceCmdlinePopupTitleHelp', colors.purple, colors.bg, nil)

Group.new('NoiceCmdlinePopupBorderSearch', colors.bg_dark, colors.bg_dark, nil)
Group.new('NoiceCmdlinePopupBorderLua', colors.bg_dark, colors.bg_dark, nil)
Group.new('NoiceCmdlinePopupBorderCmdline', colors.bg_dark, colors.bg_dark, nil)
Group.new('NoiceCmdlinePopupBorderHelp', colors.bg_dark, colors.bg_dark, nil)

Group.new('NoiceCmdline', colors.white, nil, styles.NONE)
Group.new('NoiceCmdlinePrompt', colors.white, nil, styles.NONE)

Group.new('NotifyBackground', nil, colors.bg, nil)

-- Mini.Jump
Group.new('MiniJump', nil, colors.keyword, nil)

-- EasyMotion
Group.new('EasyMotionTarget', colors.yellow, colors.bg, styles.bold)

-- CSS
Group.new('@property.css', colors.green_light, nil, nil)
Group.new('@function.css', colors.yellow_muted, nil, nil)
Group.new('@string.css', colors.yellow_light, nil, nil)
Group.new('@number.css', colors.yellow_light, nil, nil)
Group.new('@number.float.css', colors.yellow_light, nil, nil)
Group.new('@variable.css', colors.blue_light, nil, nil)
Group.new('@attribute.css', colors.green, nil, nil)
Group.new('@constant.css', colors.yellow_light, nil, nil)
Group.new('@type.css', colors.yellow_light, nil, nil)
Group.new('@keyword.operator.css', colors.green, nil, nil)
Group.new('@tag.attribute.css', colors.green, nil, nil)

-- Biscuits
Group.new('BiscuitColor', colors.keyword, nil, nil)
