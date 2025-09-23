local set = vim.keymap.set

set('n', '<leader>rb', function()
  require('kulala').scratchpad()
end, { desc = 'Open scratchpad' })
set('n', '<leader>ro', function()
  require('kulala').open()
end, { desc = 'Open kulala' })

set({ 'n' }, '<leader>rt', function()
  require('kulala').toggle_view()
end, { desc = 'Toggle headers/body' })
set({ 'n' }, '<leader>rS', function()
  require('kulala').show_stats()
end, { desc = 'Show stats' })

set({ 'n' }, '<leader>rq', function()
  require('kulala').close()
end, { desc = 'Close window' })

set({ 'n' }, '<leader>rc', function()
  require('kulala').copy()
end, { desc = 'Copy as cURL' })

set({ 'n' }, '<leader>rC', function()
  require('kulala').from_curl()
end, { desc = 'Paste from curl' })

set({ 'n', 'v' }, '<leader>rs', function()
  require('kulala').run()
end, { desc = 'Send request' })

set({ 'n', 'v' }, '<leader>r<CR>', function()
  require('kulala').run()
end, { desc = 'Send request <cr>' })

set({ 'n', 'v' }, '<leader>ra', function()
  require('kulala').run_all()
end, { desc = 'Send all requests' })

set({ 'n' }, '<leader>ri', function()
  require('kulala').inspect()
end, { desc = 'Inspect current request' })

set({ 'n' }, '<leader>rr', function()
  require('kulala').replay()
end, { desc = 'Replay the last request' })

set({ 'n' }, '<leader>rf', function()
  require('kulala').search()
end, { desc = 'Find request' })

set({ 'n' }, '<leader>rn', function()
  require('kulala').jump_next()
end, { desc = 'Jump to next request' })

set({ 'n' }, '<leader>rp', function()
  require('kulala').jump_prev()
end, { desc = 'Jump to previous request' })

set({ 'n' }, '<leader>re', function()
  require('kulala').set_selected_env()
end, { desc = 'Select environment' })

set({ 'n' }, '<leader>ru', function()
  require('lua.kulala.ui.auth_manager').open_auth_config()
end, { desc = 'Manage Auth Config' })

set({ 'n' }, '<leader>rg', function()
  require('kulala').download_graphql_schema()
end, { desc = 'Download GraphQL schema' })

set({ 'n' }, '<leader>rx', function()
  require('kulala').scripts_clear_global()
end, { desc = 'Clear globals' })

set({ 'n' }, '<leader>rX', function()
  require('kulala').clear_cached_files()
end, { desc = 'Clear cached files' })
