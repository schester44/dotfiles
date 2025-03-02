---@class KeymapOptions
---@field keys string
---@field cmd string | function
---@field desc string

---@param key string
---@param desc_prefix string
local function create_keymap_group(key, desc_prefix)
  ---@param opts KeymapOptions
  return function(opts)
    vim.keymap.set('n', key .. opts.keys, opts.cmd, { desc = desc_prefix .. opts.desc })
  end
end

local M = {}

M.set_toggle_keymap = create_keymap_group('<leader>T', '')
M.set_test_keymap = create_keymap_group('<leader>t', '')

return M
