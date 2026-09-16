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
    -- obsidian.nvim compatibility: don't fight over concealing
    file_types = { 'markdown' },
  },
}
