-- Colored block quotes: start a quote with a tag to color its bar, title and body.
--   > !red This whole quote is red
--   > !alert Same, with an alert icon
-- Highlight groups (MdQuote*) are defined in grapelean/plugins/render-markdown.lua.
local quote_colors = {
  -- tag      = { highlight group, icon }
  red         = { 'MdQuoteRed', '󰀪' },
  alert       = { 'MdQuoteRed', '󰀪' },
  error       = { 'MdQuoteRed', '󱐌' },
  yellow      = { 'MdQuoteYellow', '󰀪' },
  warn        = { 'MdQuoteYellow', '󰀪' },
  green       = { 'MdQuoteGreen', '󰄬' },
  ok          = { 'MdQuoteGreen', '󰄬' },
  blue        = { 'MdQuoteBlue', '󰋽' },
  info        = { 'MdQuoteBlue', '󰋽' },
  purple      = { 'MdQuotePurple', '󰌶' },
  gray        = { 'MdQuoteGray', '󰘥' },
  dim         = { 'MdQuoteGray', '󰘥' },
}

-- Custom handler for quotes whose first line starts with `!tag`:
--   * colors the body text (treesitter would make it blue)
--   * recolors the quote bar (drawn over the builtin one)
--   * `!tag ` is hidden; `!!tag` is replaced by the tag's icon
--     (raw text shows on the cursor line)
local quote_query
local function color_quotes(ctx)
  quote_query = quote_query or vim.treesitter.query.parse('markdown', '(block_quote) @quote')
  local icon = '▋' -- keep in sync with quote.icon (default)
  local marks = {}
  for _, node in quote_query:iter_captures(ctx.root, ctx.buf) do
    local start_row, start_col, end_row, end_col = node:range()
    local lines = vim.api.nvim_buf_get_lines(ctx.buf, start_row, end_row + 1, false)
    local tag_s, bangs, tag, tag_e = (lines[1] or ''):match('^%s*>%s*()(!!?)(%w+)()', start_col + 1)
    local spec = tag and quote_colors[tag:lower()]
    if spec then
      local hl = spec[1]
      -- body text
      marks[#marks + 1] = {
        conceal = false, -- keep the color on the cursor line too
        start_row = start_row,
        start_col = start_col,
        opts = { end_row = end_row, end_col = end_col, hl_group = hl, priority = 110 },
      }
      -- `!!tag` -> icon, `!tag ` -> nothing (also hide the following space)
      local with_icon = bangs == '!!'
      if not with_icon and lines[1]:sub(tag_e, tag_e) == ' ' then
        tag_e = tag_e + 1
      end
      marks[#marks + 1] = {
        conceal = true,
        start_row = start_row,
        start_col = tag_s - 1,
        opts = {
          end_row = start_row,
          end_col = tag_e - 1,
          conceal = '',
          virt_text = with_icon and { { spec[2], hl } } or nil,
          virt_text_pos = with_icon and 'inline' or nil,
        },
      }
      -- quote bar on every line of this quote
      for i, line in ipairs(lines) do
        local row = start_row + i - 1
        local col = row <= end_row and line:find('>', start_col + 1, true)
        if col and not (row == end_row and col > end_col) then
          marks[#marks + 1] = {
            conceal = true,
            start_row = row,
            start_col = col - 1,
            opts = {
              end_row = row,
              end_col = col,
              virt_text = { { icon, hl } },
              virt_text_pos = 'overlay',
              virt_text_repeat_linebreak = true,
              priority = 5000, -- above the builtin bar (4096)
            },
          }
        end
      end
    end
  end
  return marks
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = { 'markdown' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    -- No sign-column marks (headings, code blocks)
    sign = { enabled = false },
    -- Render horizontal rules (---) as a full-width line
    dash = {
      enabled = true,
      icon = '─',
      width = 'full',
    },
    -- Headings: keep literal # markers, hierarchy via color + background bands
    heading = {
      icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
      position = 'inline',
      width = { 'full', 'full', 'block' }, -- bg band: full-width H1/H2, snug H3+
      border = true, -- half-block border above/below all heading levels
      border_virtual = true, -- draw via virtual lines; no blank lines required
    },
    -- Links: default icons + styled text (colors come from the grapelean theme)
    link = {
      enabled = true,
    },
    -- Gray out the full text of completed checkbox items
    checkbox = {
      checked = {
        scope_highlight = 'RenderMarkdownCheckedScope',
      },
      custom = {
        in_progress = {
          raw = '[~]',
          rendered = '󱂫 ',
          highlight = 'RenderMarkdownInProgress',
        },
      },
    },
    -- Repeat the quote bar on wrapped lines (needs showbreak/breakindent, see ftplugin/markdown.lua)
    quote = { repeat_linebreak = true },
    custom_handlers = {
      markdown = { extends = true, parse = color_quotes },
    },
    -- obsidian.nvim compatibility: don't fight over concealing
    file_types = { 'markdown' },
  },
}
