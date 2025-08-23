return {
  'ahmedkhalf/project.nvim',
  cond = not vim.g.vscode,
  config = function()
    require('project_nvim').setup {
      manual_mode = false,
      detection_methods = { 'lsp', 'pattern' },
      patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json', 'pom.xml', 'Cargo.toml' },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = false,
      silent_chdir = true,
      scope_chdir = 'global',
      datapath = vim.fn.stdpath 'data',
    }

    vim.keymap.set('n', '<leader>sp', function()
      -- Use Snacks picker for projects
      local projects = require('project_nvim').get_recent_projects()
      local items = {}
      
      for _, project in ipairs(projects) do
        table.insert(items, {
          label = vim.fn.fnamemodify(project, ':t') .. ' - ' .. project,
          value = project,
          file = project,
        })
      end

      Snacks.picker {
        title = 'Projects',
        items = items,
        format = function(item)
          return item.label
        end,
        actions = {
          default = function(item)
            vim.cmd('cd ' .. item.value)
            vim.cmd('edit .')
          end,
        },
      }
    end, { desc = 'Find Projects' })
  end,
}