local M = {}

M.custom_path = function(str)
  if not str or str == '' then
    return vim.fn.stdpath 'config' .. '/lua/custom'
  end

  return vim.fn.stdpath 'config' .. '/lua/custom/' .. str
end

M.gh = function(x) return 'https://github.com/' .. x end

---@class plugins.Ctx
---@field name string Plugin name (inferred from src or explicit `name`)
---@field map fun(mode: string|string[], lhs: string, rhs: string|function, opts?: vim.keymap.set.Opts) vim.keymap.set

---@class plugins.Spec : vim.pack.Spec
---@field opts? table|fun(ctx: plugins.Ctx): table? If table, passed to require(name).setup(). If function, called with a plugins.Ctx. If the function returns a table, it's passed to require(name).setup().

--- Add plugins via vim.pack and auto-setup.
--- If `src` doesn't include a protocol, it's prefixed with `https://github.com/`.
---@param specs (string|plugins.Spec)[]
M.add = function(specs)
  local to_setup = {}

  local pack_specs = {}
  for _, spec in ipairs(specs) do
    if type(spec) == 'string' then
      table.insert(pack_specs, spec)
    else
      local opts = spec.opts
      spec.opts = nil

      if not spec.src:match('^https?://') then
        spec.src = M.gh(spec.src)
      end

      table.insert(pack_specs, spec)

      if opts ~= nil then
        local name = spec.name or spec.src:match('[^/]+$'):gsub('%.nvim$', ''):gsub('%.lua$', '')
        table.insert(to_setup, { name = name, opts = opts })
      end
    end
  end

  vim.pack.add(pack_specs)

  for _, plug in ipairs(to_setup) do
    if type(plug.opts) == 'function' then
      local mod = require(plug.name)
      local setup_called = false
      if mod.setup then
        local original_setup = mod.setup
        mod.setup = function(...)
          setup_called = true
          return original_setup(...)
        end
      end

      local result = plug.opts({
        name = plug.name,
        map = vim.keymap.set,
      })

      if not setup_called and mod.setup then
        mod.setup(type(result) == 'table' and result or {})
      end
    else
      require(plug.name).setup(plug.opts or {})
    end
  end
end

return M
