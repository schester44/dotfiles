local state = {
  current_element_index = nil,
  components = {},
}

function state.set(new_state)
  for key, value in pairs(new_state) do
    if value == vim.NIL then
      value = nil
    end
    state[key] = value
  end
end

local M = {}

local function open_buf(id)
  if vim.api.nvim_buf_is_valid(id) then
    vim.api.nvim_set_current_buf(id)
  end
end

---@return number
local function get_current_element()
  return vim.api.nvim_get_current_buf()
end

function M.is_valid(buf)
  if not buf.bufnr or buf.bufnr < 1 then
    return false
  end
  local valid = vim.api.nvim_buf_is_valid(buf.bufnr)
  if not valid then
    return false
  end
  return buf.listed == 1
end

function M.get_current_element_index(current_state)
  local list = current_state.components

  for index, item in ipairs(list) do
    if item and item.id == get_current_element() then
      return index, item
    end
  end
end

---@return integer[]
function M.get_valid_buffers()
  local bufs = vim.fn.getbufinfo()
  local valid_bufs = {}
  for _, buf in ipairs(bufs) do
    if M.is_valid(buf) then
      table.insert(valid_bufs, buf.bufnr)
    end
  end
  return valid_bufs
end

function M.get_components()
  local buf_nums = M.get_valid_buffers()

  local components = {}

  for i, buf_id in ipairs(buf_nums) do
    local buf = {
      path = vim.api.nvim_buf_get_name(buf_id),
      id = buf_id,
      ordinal = i,
    }

    components[i] = buf
  end

  return components
end

function M.cycle(direction)
  local index = M.get_current_element_index(state)

  if not index then
    return
  end

  local length = #state.components
  local next_index = index + direction

  if next_index <= length and next_index >= 1 then
    next_index = index + direction
  elseif index + direction <= 0 then
    next_index = length
  else
    next_index = 1
  end

  local item = state.components[next_index]

  if not item then
    return print 'Buffer does not exist'
  end

  open_buf(item.id)
end

local function reinit_state()
  local components = M.get_components()

  local current_idx = nil

  for i, component in ipairs(components) do
    if vim.api.nvim_get_current_buf() == component.id then
      current_idx = i
    end
  end

  state.set {
    current_element_index = current_idx,
    components = components,
  }
end

local function setup_autocommands()
  vim.api.nvim_create_autocmd('BufRead', {
    pattern = '*',
    once = true,
    callback = function()
      reinit_state()
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = function()
      reinit_state()
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout', 'BufUnload' }, {
    pattern = '*',
    callback = function()
      reinit_state()
    end,
  })
end

local function command(name, cmd, opts)
  vim.api.nvim_create_user_command(name, cmd, opts or {})
end

local function setup_commands()
  command('BuffyCycleNext', function()
    M.cycle(1)
  end)

  command('BuffyCyclePrev', function()
    M.cycle(-1)
  end)
end

M.setup = function()
  setup_autocommands()
  setup_commands()
  reinit_state()
end

return M
