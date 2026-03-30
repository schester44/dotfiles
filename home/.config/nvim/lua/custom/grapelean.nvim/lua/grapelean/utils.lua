local M = {}

function M.hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

function M.link(name, target)
  vim.api.nvim_set_hl(0, name, { link = target })
end

return M
