local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette

hl('FidgetTask',  { fg = p.blue,   bg = p.bg })
hl('FidgetTitle', { fg = p.yellow, bg = p.bg, bold = true })
