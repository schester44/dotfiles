local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('LualineRecording',        { fg = p.red })
hl('LualineCopilotOffline',   { fg = p.red })
hl('LualinePath',             { fg = s.keyword })
hl('LualineFilename',         { fg = p.gray_light })
hl('LualineFilenameModified', { fg = p.yellow_light, italic = true })
