return {
  'vuki656/package-info.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  event = 'BufRead package.json',
  config = function()
    require('package-info').setup {
      hide_up_to_date = true, -- only annotate outdated dependencies
    }

    vim.api.nvim_create_autocmd('BufRead', {
      pattern = 'package.json',
      callback = function(ev)
        local pi = require 'package-info'
        local function map(lhs, fn, desc)
          vim.keymap.set('n', lhs, fn, { buffer = ev.buf, desc = desc })
        end
        map('<leader>ns', pi.show, 'Show dependency versions')
        map('<leader>nh', pi.hide, 'Hide dependency versions')
        map('<leader>nt', pi.toggle, 'Toggle dependency versions')
        map('<leader>nu', pi.update, 'Update dependency on line')
        map('<leader>nd', pi.delete, 'Delete dependency on line')
        map('<leader>ni', pi.install, 'Install a new dependency')
        map('<leader>nc', pi.change_version, 'Change dependency version')
      end,
    })

    -- Keymaps also apply to the buffer that triggered this plugin load
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match 'package%.json$' then
      vim.api.nvim_exec_autocmds('BufRead', { pattern = 'package.json' })
    end
  end,
}
