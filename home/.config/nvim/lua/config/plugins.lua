local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'
for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  local mod = file:match('^(.+)%.lua$')
  if mod then
    require('plugins.' .. mod)
  end
end
