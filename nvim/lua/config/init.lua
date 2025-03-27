if vim.g.vscode then
  require 'config.vscode'
else
  require 'config.options'
  require 'config.autocmds'
  require 'config.keymaps'
  require 'config.lazy'
  require 'config.cmds'
end
