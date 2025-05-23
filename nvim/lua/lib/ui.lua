local M = {}

M.border_chars_none = { '', '', '', '', '', '', '', '' }
M.border_chars_empty = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }

M.border_chars_inner_thick = { ' ', '▄', ' ', '▌', ' ', '▀', ' ', '▐' }
M.border_chars_outer_thick = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' }

M.border_chars_outer_thin = { '🭽', '▔', '🭾', '▕', '🭿', '▁', '🭼', '▏' }
M.border_chars_inner_thin = { ' ', '▁', ' ', '▏', ' ', '▔', ' ', '▕' }

M.top_right_corner_thin = '🭾'
M.top_left_corner_thin = '🭽'

M.border_chars_outer_thin_telescope = { '▔', '▕', '▁', '▏', '🭽', '🭾', '🭿', '🭼' }
M.border_chars_outer_thick_telescope = { '▀', '▐', '▄', '▌', '▛', '▜', '▟', '▙' }

-- @param {string} hl
-- @param {string} str
M.hl_str = function(hl, str)
  return '%#' .. hl .. '#' .. str .. '%*'
end

return M
