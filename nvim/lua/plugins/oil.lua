local ui = require 'lib.ui'

local function oil_files_to_quickfix()
  if vim.bo.filetype ~= 'oil' then
    return
  end
  local oil = require 'oil'
  local dir = oil.get_current_dir()

  local entries = {}
  for i = 1, vim.fn.line '$' do
    local entry = oil.get_entry_on_line(0, i)
    if entry and entry.type == 'file' then
      table.insert(entries, { filename = dir .. entry.name })
    end
  end
  if #entries == 0 then
    return
  end

  vim.fn.setqflist(entries)
  return vim.cmd.copen()
end

return {
  'stevearc/oil.nvim',
  cond = not vim.g.vscode,
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  config = function()
    require('oil').setup {
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return name == '.git' or name == '.DS_Store'
        end,
      },
      float = { padding = 2, max_width = 120, max_height = 50, border = ui.border_chars_outer_thin },

      keymaps = {
        ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
        ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
        ['<C-q>'] = oil_files_to_quickfix,
      },
    }

    vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = 'Open parent directory' })
  end,
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
