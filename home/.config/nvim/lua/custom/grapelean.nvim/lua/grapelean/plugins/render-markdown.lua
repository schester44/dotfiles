local hl    = require('grapelean.utils').hl
local pal   = require 'grapelean.palette'
local p     = pal.palette
local blend = require('grapelean.color').blend

-- Headings: consistent red for marker and text at every level
hl('RenderMarkdownH1', { fg = p.red, bold = true })
hl('RenderMarkdownH2', { fg = p.red, bold = true })
hl('RenderMarkdownH3', { fg = p.red, bold = true })
hl('RenderMarkdownH4', { fg = p.red })
hl('RenderMarkdownH5', { fg = p.red })
hl('RenderMarkdownH6', { fg = p.red })

-- Treesitter groups color the heading *text*; keep them in sync with the marker
for i = 1, 6 do
  hl('@markup.heading.' .. i .. '.markdown', { link = 'RenderMarkdownH' .. i })
end

-- Neutral bands darker than the page background; H1 darkest
hl('RenderMarkdownH1Bg', { bg = blend(p.black, p.bg, 0.40) })
hl('RenderMarkdownH2Bg', { bg = blend(p.black, p.bg, 0.30) })
hl('RenderMarkdownH3Bg', { bg = blend(p.black, p.bg, 0.20) })
hl('RenderMarkdownH4Bg', { bg = blend(p.black, p.bg, 0.12) })
hl('RenderMarkdownH5Bg', { bg = blend(p.black, p.bg, 0.12) })
hl('RenderMarkdownH6Bg', { bg = blend(p.black, p.bg, 0.12) })

-- Links: green + underline — green means go (markdown links and obsidian wiki links)
hl('RenderMarkdownLink',     { fg = p.green, underline = true })
hl('RenderMarkdownWikiLink', { fg = p.green, underline = true })

-- Underlying treesitter groups so the link *text* matches, not just the icon
hl('@markup.link.label.markdown_inline', { fg = p.green, underline = true })
hl('@markup.link.markdown_inline',       { fg = p.green_muted })
hl('@markup.link.url.markdown_inline',   { fg = p.green_muted, underline = true })

-- Checkboxes: green box for open items, gray/dimmed for done
hl('RenderMarkdownUnchecked',    { fg = p.green })
hl('RenderMarkdownChecked',      { fg = p.gray })
-- Completed items: gray out the whole line
hl('RenderMarkdownCheckedScope', { fg = p.gray, strikethrough = false })

-- In-progress [~] items: purple (distinct from green open / gray done, not orange)
hl('RenderMarkdownInProgress', { fg = p.purple })

-- Raw-text (cursor line / insert mode) checkbox brackets: match the rendered colors
hl('@markup.list.unchecked.markdown', { link = 'RenderMarkdownUnchecked' })
hl('@markup.list.checked.markdown',   { link = 'RenderMarkdownChecked' })
