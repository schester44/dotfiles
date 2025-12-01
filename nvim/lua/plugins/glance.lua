vim.keymap.set('n', 'gD', '<CMD>Glance definitions<CR>')
vim.keymap.set('n', 'gt', '<CMD>Glance type_definitions<CR>')
vim.keymap.set('n', 'gm', '<CMD>Glance implementations<CR>')

return {
  'dnlhc/glance.nvim',
  cmd = 'Glance',
  opts = {

    list = {
      position = 'right',
      width = 0.45,
    },
  },
}
