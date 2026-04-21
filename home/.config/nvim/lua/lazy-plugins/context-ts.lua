return {
  'andersevenrud/nvim_context_vt',
  event = 'BufReadPost',
  config = function()
    -- Dim peach — warm but subdued, distinct from gray comments (#626262)
    vim.api.nvim_set_hl(0, 'NvimContextVt', { fg = '#564a3a', italic = true })

    require('nvim_context_vt').setup {
      prefix = ' ->',
      highlight = 'NvimContextVt',
      min_rows = 5,
      disable_ft = { 'yaml' },
    }
  end,
}
