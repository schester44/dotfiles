return {
  'sphamba/smear-cursor.nvim',
  cond = not vim.g.vscode,
  opts = {
    cursor_color = '#AD8F17',
    normal_bg = '#1C2E41',
    stiffness = 1,
    trailing_stiffness = 0.4,
    stiffness_insert_mode = 0.6,
    trailing_stiffness_insert_mode = 0.6,
    distance_stop_animating = 0.5,
  },
}
