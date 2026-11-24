-- rest.nvim's rockspec pins `tree-sitter-http == 0.0.35`, which isn't published
-- for Lua 5.1, so lazy's rockspec build fails. Install the runtime rocks ourselves
-- (the http parser comes from nvim-treesitter instead).
local rocks = { 'nvim-nio', 'mimetypes', 'xml2lua', 'fidget.nvim' }

return {
  'rest-nvim/rest.nvim',
  ft = { 'http' },
  cmd = 'Rest',
  build = function(plugin)
    local root = vim.fn.stdpath 'data' .. '/lazy-rocks'
    local luarocks = vim.fn.executable 'luarocks' == 1 and 'luarocks' or (root .. '/hererocks/bin/luarocks')
    for _, rock in ipairs(rocks) do
      local out = vim.system({
        luarocks,
        '--tree',
        root .. '/' .. plugin.name,
        '--server',
        'https://lumen-oss.github.io/rocks-binaries/',
        '--lua-version',
        '5.1',
        'install',
        rock,
      }, { text = true }):wait()
      if out.code ~= 0 then
        error('rest.nvim: failed installing ' .. rock .. '\n' .. (out.stderr or ''))
      end
    end
  end,
  init = function()
    ---@type rest.Opts
    vim.g.rest_nvim = {}
  end,
}
