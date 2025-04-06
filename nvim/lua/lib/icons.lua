local M = {}

M.icons = {
  branch = '',
  bullet = '•',
  o_bullet = '○',
  check = '✔',
  ellipses = '…',
  hamburger = '≡',
  r_chev = '>',
  up_tri = '▲',

  x_circle = '󰅙',
  info_circle = '󰋼',
  bulb = '󰌵',

  code = '',
  diagnostics = '',
  file = '',
  git = '󰊢',
  note = '',
  search = '',
  test = '󰱑',
  toggle = '',
  kinds = {
    CopilotOnline = '',
    CopilotOffline = '',
  },
}

M.diagnostics = {
  error = M.icons.x_circle,
  warn = M.icons.up_tri,
  info = M.icons.info_circle,
  hint = M.icons.bulb,
}

return M
