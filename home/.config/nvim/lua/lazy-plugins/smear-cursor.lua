local json_path = vim.fn.expand '~/.dotfiles/system/theme.json'
local file = io.open(json_path, 'r')
local theme = file and vim.json.decode(file:read '*a') or {}
if file then
  file:close()
end

return {
  'sphamba/smear-cursor.nvim',
  cond = not vim.g.vscode,
  opts = {
    cursor_color = theme.semantic and theme.semantic.cursor or '#d4b870',
    normal_bg = theme.palette and theme.palette.bg.base or '#202024',
    stiffness = 1,
    trailing_stiffness = 0.4,
    stiffness_insert_mode = 0.6,
    trailing_stiffness_insert_mode = 0.6,
    distance_stop_animating = 0.5,
  },
  config = function(_, opts)
    require('smear_cursor').setup(opts)

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniPickStart',
      callback = function()
        require('smear_cursor').enabled = false
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniPickStop',
      callback = function()
        require('smear_cursor').enabled = true
      end,
    })
  end,
}
