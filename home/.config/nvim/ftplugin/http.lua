local set = vim.keymap.set
local opts = function(desc)
  return { buffer = true, desc = desc }
end

set('n', '<leader>rr', '<cmd>Rest run<cr>', opts 'Send request')
set('n', '<leader>ro', '<cmd>Rest open<cr>', opts 'Open result pane')
set('n', '<leader>rc', '<cmd>Rest curl yank<cr>', opts 'Copy as cURL')
set('n', '<leader>rC', '<cmd>Rest curl comment<cr>', opts 'Insert cURL as comment')
set('n', '<leader>re', '<cmd>Rest env select<cr>', opts 'Select environment')
set('n', '<leader>rE', '<cmd>Rest env show<cr>', opts 'Show environment')
set('n', '<leader>rl', '<cmd>Rest last<cr>', opts 'Replay the last request')
set('n', '<leader>rL', '<cmd>Rest logs<cr>', opts 'Open logs')
set('n', '<leader>rk', '<cmd>Rest cookies<cr>', opts 'Open cookies')

set('n', '<leader>rn', function()
  vim.fn.search('^###', 'W')
end, opts 'Jump to next request')
set('n', '<leader>rp', function()
  vim.fn.search('^###', 'bW')
end, opts 'Jump to previous request')
