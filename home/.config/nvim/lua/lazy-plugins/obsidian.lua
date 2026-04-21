local vault_path = '~/Documents/Obsidian/Vault'

vim.keymap.set('n', '<leader>on', '<cmd>Obsidian new<CR>', { desc = 'Obsidian New' })
vim.keymap.set('n', '<leader>ot', '<cmd>Obsidian today<CR>', { desc = 'Obsidian Today' })
vim.keymap.set('n', '<leader>ox', '<cmd>e ~/Documents/Obsidian/Vault/TODAY.md<CR>', { desc = 'Obsidian Scratch' })

-- Buffer-local keymaps for obsidian notes only
vim.api.nvim_create_autocmd('User', {
  pattern = 'ObsidianNoteEnter',
  callback = function(ev)
    vim.keymap.set('n', '<leader>ob', '<cmd>Obsidian backlinks<CR>', { buffer = ev.buf, desc = 'Obsidian Backlinks' })
    vim.keymap.set('n', '<leader>ol', '<cmd>Obsidian links<CR>', { buffer = ev.buf, desc = 'Obsidian Links' })
  end,
})

-- Use mini.pick for vault search
-- NOTE: --no-ignore needed because vault .gitignore excludes everything
local vault_resolved = vim.fn.expand(vault_path)
local vault_rg_base = { 'rg', '--no-ignore', '--glob', '!.obsidian', '--glob', '!.git' }

-- Save cwd before picker starts, restore it when picker closes
local function with_cwd_restore(fn)
  return function()
    local original_cwd = vim.fn.getcwd()
    local restore_id
    restore_id = vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniPickStop',
      once = true,
      callback = function()
        vim.cmd.cd(original_cwd)
      end,
    })
    fn()
  end
end

vim.keymap.set('n', '<leader>oo', with_cwd_restore(function()
  local cmd = vim.list_extend(vim.list_extend({}, vault_rg_base), { '--files', '--color=never' })
  MiniPick.builtin.cli(
    { command = cmd },
    { source = { name = 'Obsidian Notes', cwd = vault_resolved } }
  )
end), { desc = 'Obsidian Find Notes' })

vim.keymap.set('n', '<leader>og', with_cwd_restore(function()
  local pattern = vim.fn.input 'Grep Obsidian> '
  if pattern == '' then
    return
  end
  local cmd = vim.list_extend(vim.list_extend({}, vault_rg_base), { '--line-number', '--column', '--color=never', '--', pattern })
  MiniPick.builtin.cli(
    { command = cmd },
    { source = { name = 'Obsidian Grep', cwd = vault_resolved } }
  )
end), { desc = 'Obsidian Grep' })

vim.keymap.set('n', '<leader>oa', with_cwd_restore(function()
  local cmd = vim.list_extend(vim.list_extend({}, vault_rg_base), { '--line-number', '--column', '--color=never', '--', '#' })
  MiniPick.builtin.cli(
    { command = cmd },
    { source = { name = 'Obsidian Tags', cwd = vault_resolved } }
  )
end), { desc = 'Obsidian Tags' })

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    picker = {
      name = 'mini.pick',
    },
    completion = {
      blink = true,
      nvim_cmp = false,
    },
    daily_notes = {
      folder = 'daily',
    },
    workspaces = {
      {
        name = 'all',
        path = vault_path,
      },
      {
        name = 'old',
        path = '~/vaults/work',
      },
    },
  },
}
