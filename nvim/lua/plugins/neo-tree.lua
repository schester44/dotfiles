-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>te', ':Neotree toggle<CR>', desc = '[T]oggle [E]xplorer', silent = true },
  },
  opts = {
    close_if_last_window = true,
    default_component_configs = {
      git_status = {
        symbols = {
          added = '✚',
          untracked = '✚',
          staged = '✓',
          unstaged = '',
          modified = '',
        },
      },
      indent = { with_markers = false, indent_size = 1, with_expanders = true },
    },
    filesystem = {
      filtered_items = { hidden = true, hide_dotfiles = false, hide_by_name = {} },
      follow_current_file = {
        enabled = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
