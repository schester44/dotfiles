return {
  {
    'CRAG666/code_runner.nvim',
    cmd = { 'RunCode', 'RunFile' },
    keys = {
      {
        '<leader>rr',
        function()
          local name = vim.api.nvim_buf_get_name(0)
          if name == '' or vim.fn.filereadable(name) == 0 then
            local tmp = vim.fn.tempname() .. '.ts'
            vim.bo.filetype = 'typescript'
            vim.cmd('write ' .. vim.fn.fnameescape(tmp))
            vim.cmd 'RunFile'
          else
            vim.cmd 'RunFile'
          end
        end,
        desc = 'Run File',
      },
    },
    opts = {
      focus = false,
      startinsert = false,
      term = {
        size = 13,
      },
      filetype = {
        javascript = 'npx tsx --watch',
        typescript = 'npx tsx --watch',
        javascriptreact = 'npx tsx --watch',
        typescriptreact = 'npx tsx --watch',
      },
    },
  },
}
