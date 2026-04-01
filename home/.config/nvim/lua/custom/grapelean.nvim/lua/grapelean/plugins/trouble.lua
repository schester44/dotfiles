local hl      = require('grapelean.utils').hl
local pal     = require 'grapelean.palette'
local p       = pal.palette
local s       = pal.semantic
local color   = require 'grapelean.color'
local lighten = color.lighten
local darken  = color.darken

hl('TroubleCode',        { fg = p.gray_light })
hl('TroubleCount',       { fg = p.yellow, bg = s.bg_selection })
hl('TroubleError',       { fg = p.red, bg = lighten(p.red) })
hl('TroubleFile',        { fg = p.blue })
hl('TroubleFoldIcon',    { fg = p.yellow })
hl('TroubleHint',        { fg = p.green })
hl('TroubleIndent',      { fg = p.gray_light })
hl('TroubleInformation', { fg = p.green })
hl('TroubleLocation',    { fg = p.pink })
hl('TroubleNormal',      { fg = p.gray_light })
hl('TroublePreview',     { fg = lighten(p.yellow), bg = darken(p.blue_dark) })
hl('TroubleSignError',   { fg = p.red })
hl('TroubleSignHint',    { fg = p.green })
hl('TroubleSignInformation',{ fg = p.blue_light })
hl('TroubleSignOther',   { fg = p.gray_light })
hl('TroubleSignWarning', { fg = s.warning })
hl('TroubleSource',      { fg = p.yellow_muted, italic = true })
hl('TroubleText',        { fg = p.gray_light })
hl('TroubleTextError',   { fg = p.red })
hl('TroubleTextHint',    { fg = p.green })
hl('TroubleTextInformation',{ fg = p.blue_light })
hl('TroubleTextWarning', { fg = s.warning })
hl('TroubleWarning',     { fg = s.warning })
