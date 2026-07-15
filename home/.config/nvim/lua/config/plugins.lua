-- Non-lazy plugin configs loaded outside of lazy.nvim
-- Add .lua files to lua/plugins/ and they will be auto-required.
local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'
local ok, files = pcall(vim.fn.readdir, plugin_dir)
if ok then
  for _, file in ipairs(files) do
    local mod = file:match('^(.+)%.lua$')
    if mod then
      require('plugins.' .. mod)
    end
  end
end
