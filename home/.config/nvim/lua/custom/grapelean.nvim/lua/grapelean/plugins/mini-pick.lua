local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

-- Mini Pick
hl('MiniPickNormal',       { fg = s.fg,          bg = s.bg_float })
hl('MiniPickBorder',       { fg = s.bg_float,    bg = s.bg_float })
hl('MiniPickBorderBusy',   { fg = p.gray_dark,   bg = s.bg_float })
hl('MiniPickBorderText',   { fg = p.gray_light,  bg = s.bg_float })
hl('MiniPickCursor',       { fg = p.white,       bg = p.bg_light })
hl('MiniPickIconDirectory',{ fg = p.blue,        bg = s.bg_float })
hl('MiniPickIconFile',     { fg = p.gray_light,  bg = s.bg_float })
hl('MiniPickHeader',       { fg = p.purple,      bg = s.bg_float })
hl('MiniPickMatchCurrent', { fg = p.yellow_light,bg = s.bg_float })
hl('MiniPickMatchMarked',  { fg = p.yellow,      bg = s.bg_float })
hl('MiniPickMatchRanges',  { fg = p.green })
hl('MiniPickPreviewLine',  { fg = p.white,       bg = p.bg_light })
hl('MiniPickPreviewRegion',{ fg = p.white,       bg = p.bg_light })
hl('MiniPickPrompt',       { fg = p.green,       bg = s.bg_float })
hl('MiniPickPromptCaret',  { fg = p.green,       bg = s.bg_float })
hl('MiniPickPromptPrefix', { fg = p.purple,      bg = s.bg_float })

-- Grep result highlighting
hl('MiniPickGrepFile', { fg = p.blue })
hl('MiniPickGrepLnum', { fg = p.gray_light })
