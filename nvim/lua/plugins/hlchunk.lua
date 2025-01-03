return {
  'shellRaining/hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('hlchunk').setup {
      chunk = {
        enable = true,
        priority = 15,
        style = {
          { fg = '#506171' },
          { fg = '#cd758f' },
        },
        use_treesitter = true,
        chars = {
          horizontal_line = '─',
          vertical_line = '│',
          left_top = '╭',
          left_bottom = '╰',
          right_arrow = '─',
        },
        textobject = '',
        max_file_size = 1024 * 1024,
        error_sign = true,
        -- animation related
        duration = 0,
        delay = 0,
      },
      line_num = {
        enable = true,
        style = '#9E9E9E',
        priority = 10,
        use_treesitter = true,
      },
    }
  end,
}
