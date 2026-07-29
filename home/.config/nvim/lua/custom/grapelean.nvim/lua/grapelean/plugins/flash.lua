local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette

hl('FlashBackdrop', { italic = true })
hl('FlashMatch',    { underline = true })
hl('FlashCurrent',  { underline = true, bold = true })
hl('FlashLabel',    { fg = p.white, bg = p.purple })
