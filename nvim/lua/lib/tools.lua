local tools = {}

tools.hl_str = function(hl, str)
  return '%#' .. hl .. '#' .. str .. '%*'
end

return tools
