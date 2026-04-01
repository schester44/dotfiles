local hl   = require('grapelean.utils').hl
local pal  = require 'grapelean.palette'
local p    = pal.palette
local s    = pal.semantic
local color   = require 'grapelean.color'
local lighten = color.lighten
local darken  = color.darken

hl('MiniStarterHeader', { fg = p.green_light })

hl('ColorColumn',    { bg = s.bg_cursorline })
hl('CommandMode',    { fg = p.black, bg = p.blue_dark })
hl('Conceal',        { fg = p.gray_muted })
hl('CurSearch',      { fg = p.bg_dark, bg = p.pink_light })
hl('Cursor',         { fg = p.yellow, bg = p.bg })
hl('CursorColumn',   { bg = s.bg_selection })
hl('CursorIM',       { fg = p.yellow, bg = p.bg })
hl('CursorLine',     { bg = p.bg })
hl('CursorLineNr',   { fg = p.yellow, bold = true })
hl('DiffAdd',        { fg = s.added })
hl('DiffChange',     { fg = s.added })
hl('DiffDelete',     { fg = s.removed })
hl('DiffText',       { fg = s.fg })
hl('Directory',      { fg = p.blue })
hl('ErrorMsg',       { fg = lighten(p.red) })
hl('FloatBorder',    { fg = p.bg_dark, bg = p.bg_dark })
hl('FloatTitle',     { fg = p.blue_light, bg = p.bg_dark })
hl('FoldColumn',     { fg = p.bg_light })
-- Folded text/background
hl('Folded',         { fg = p.purple, italic = true })
hl('FoldedText',     { fg = s.keyword })
hl('MoreMsg',        { fg = p.yellow_light })

hl('IncSearch',      { fg = p.black, bg = p.yellow })
hl('InsertMode',     { fg = p.black, bg = s.keyword })
hl('LineNr',         { fg = p.gray_muted })
hl('MatchParen',     { fg = p.white, bg = p.purple_dark, bold = true })
hl('MatchWord',      { fg = p.white, bg = p.purple_dark, bold = true })
hl('ModeMsg',        { fg = p.white, bold = true })
hl('NonText',        { fg = p.gray_muted })
-- Controls the background color of the editor (nil for transparency)
hl('Normal',         { fg = p.white })

-- Controls the background color of autocomplete popup, oil.nvim, whichkey, floating windows, etc
hl('NormalFloat',    { fg = p.white, bg = p.bg_dark })
hl('NormalMode',     { fg = p.black, bg = p.yellow })
hl('NormalNC',       { fg = p.white })

hl('LazyGitFloat',  { bg = p.bg_dark })
hl('LazyGitBorder', { fg = p.bg_dark, bg = p.bg_dark })

hl('CmpNormal',      { fg = p.white, bg = p.bg_dark })
-- Controls the color of the selected item
hl('CmpCursorLine',  { fg = p.yellow_light, bg = p.bg })
hl('CmpDocNormal',   { fg = p.white, bg = p.bg_dark })

hl('PMenu',          { fg = p.white, bg = p.bg_dark })
hl('PMenuSBar',      { bg = p.bg })

hl('PmenuSel',       { fg = p.yellow_light, bg = p.bg })
hl('PMenuThumb',     { bg = p.bg_dark })

hl('Question',       { fg = p.green })
hl('QuickFixLine',   { bg = s.bg_selection })
hl('ReplacelMode',   { fg = p.black, bg = p.pink })
hl('Search',         { fg = p.bg_dark, bg = s.search })
hl('SignColumn',     {})
hl('SpecialKey',     { fg = p.blue_light, bg = p.bg })
hl('SpellBad',       { fg = p.red, underline = true })
hl('SpellCap',       { bg = p.purple_dark, underline = true })
hl('SpellLocal',     { bg = p.green_dark, underline = true })
hl('SpellRare',      { bg = p.red_dark, underline = true })
hl('StatusLineNC',   { fg = p.white })
hl('StatusLine',     { fg = p.yellow })

hl('TabLine',        { fg = p.gray_light, bg = p.bg })
hl('TabLineFill',    { fg = p.gray_light })
hl('TabLineSel',     { fg = p.yellow_light, bg = p.bg_light })

hl('Title',          { fg = p.green_muted, bold = true })
hl('VertSplit',      { fg = p.gray_dark })
hl('Visual',         { bg = s.bg_visual })
hl('VisualMode',     { fg = p.black, bg = p.pink_muted })
hl('VisualNOS',      { bg = p.purple_dark })
hl('WarningMsg',     { fg = p.yellow_light })
hl('Warnings',       { fg = p.yellow_light })
hl('Whitespace',     { fg = p.gray_muted })
hl('WildMenu',       { fg = p.blue, bg = p.yellow })
hl('WinBar',         { fg = p.yellow })
hl('healthError',    { fg = lighten(p.red) })
hl('healthSuccess',  { fg = p.green })
hl('healthWarning',  { fg = p.yellow_light })
hl('qfLineNr',       { fg = p.gray_light, bg = p.bg })

hl('WinSeparator',   { fg = p.gray_dark })

-- Mini.Jump
hl('MiniJump',       { bg = s.keyword })

-- EasyMotion
hl('EasyMotionTarget', { fg = p.yellow, bg = p.bg, bold = true })

-- CSS
hl('@property.css',        { fg = p.green_light })
hl('@function.css',        { fg = p.yellow_muted })
hl('@string.css',          { fg = p.yellow_light })
hl('@number.css',          { fg = p.yellow_light })
hl('@number.float.css',    { fg = p.yellow_light })
hl('@variable.css',        { fg = p.blue_light })
hl('@attribute.css',       { fg = p.green })
hl('@constant.css',        { fg = p.yellow_light })
hl('@type.css',            { fg = p.yellow_light })
hl('@keyword.operator.css',{ fg = p.green })
hl('@tag.attribute.css',   { fg = p.green })

-- Biscuits
hl('BiscuitColor', { fg = s.keyword })

-- nvim.lua groups (merged in)
hl('NvimInvalidStringSpecial', { fg = p.green })
hl('NvimStringSpecial',        { fg = p.green })
