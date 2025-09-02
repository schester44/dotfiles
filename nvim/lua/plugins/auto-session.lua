return {
  'rmagatti/auto-session',
  cond = not vim.g.vscode,
  lazy = false,
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    session_lens = {
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = false,
    },
  },
  keys = {
    -- Will use Snacks picker for session management since we're using Snacks
    {
      '<leader>ss',
      function()
        require('auto-session.session-lens').search_session()
      end,
      desc = 'Session search',
    },
    {
      '<leader>sd',
      function()
        require('auto-session').DeleteSession()
      end,
      desc = 'Delete session',
    },
  },
}