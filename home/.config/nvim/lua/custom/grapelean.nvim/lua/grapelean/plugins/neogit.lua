local hl  = require('grapelean.utils').hl
local pal = require 'grapelean.palette'
local p   = pal.palette
local s   = pal.semantic

hl('NeogitDiffAddHighlight',    { fg = s.added })
hl('NeogitDiffAddRegion',       { fg = s.added })
hl('NeogitDiffContextHighlight',{})
hl('NeogitDiffDeleteHighlight', { fg = s.removed })
hl('NeogitDiffDeleteRegion',    { fg = p.red })
hl('NeogitHunkHeaderHighlight', { fg = p.yellow, bg = p.bg_light, bold = true })
hl('NeogitHunkHeaderCursor',    { fg = p.yellow, bg = p.bg_lighter, bold = true })

-- status buffer
hl('NeogitBranch',     { fg = p.green })
hl('NeogitFold',       { fg = p.blue })
hl('NeogitBranchHead', { fg = p.red, bold = true })
hl('NeogitRemote',     { fg = p.pink })
hl('NeogitObjectId',   { fg = p.blue })
hl('NeogitStash',      { fg = p.pink_light })
hl('NeogitRebaseDone', { fg = p.green })
hl('NeogitTagName',    { fg = p.yellow })
hl('NeogitTagDistance',{ fg = p.yellow_muted })

-- status and commit buffer
hl('NeogitHunkHeader',  { fg = p.yellow, bg = p.bg_light, bold = true })
hl('NeogitDiffContext', { bg = p.bg })
hl('NeogitDiffDelete',  { fg = p.red })
hl('NeogitDiffHeader',  { fg = p.blue })
hl('NeogitDiffAdd',     { fg = p.green })

-- applied to filenames
hl('NeogitChangeModified',    { fg = p.yellow_light })
hl('NeogitChangeAdded',       { fg = p.green, bold = true })
hl('NeogitChangeDeleted',     { fg = p.red, bold = true })
hl('NeogitChangeRenamed',     { fg = p.pink_muted, bold = true })
hl('NeogitChangeUpdated',     { fg = p.green, bold = true })
hl('NeogitChangeCopied',      { fg = p.yellow, bold = true })
hl('NeogitChangeBothModified',{ fg = p.red, bold = true })
hl('NeogitChangeNewFile',     { fg = p.green, bold = true })

-- commit buffer
hl('NeogitFilePath',          { fg = p.pink, bold = true })
hl('NeogitCommitViewHeader',  { fg = p.blue })

hl('NeogitChangeMStaged', { fg = p.green })
hl('neogitremote',        { fg = s.keyword })
