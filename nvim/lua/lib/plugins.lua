local M = {}

M.custom_path = function(str)
  if not str or str == '' then
    return vim.fn.stdpath 'config' .. '/lua/custom'
  end

  return vim.fn.stdpath 'config' .. '/lua/custom/' .. str
end

return M
