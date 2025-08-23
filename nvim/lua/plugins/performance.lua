return {
  -- Startup time profiler
  {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    cond = not vim.g.vscode,
    init = function()
      vim.g.startuptime_tries = 10
    end,
  },
  
  -- Better startup optimization
  {
    'lewis6991/impatient.nvim',
    cond = not vim.g.vscode,
    config = function()
      require('impatient').enable_profile()
    end,
  },
}