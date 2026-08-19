-- Treesitter-based outline of test blocks (describe/context/it/test) for the
-- current buffer, shown in a mini.pick picker.

local M = {}

local KEYWORDS = {
  describe = true,
  context = true,
  it = true,
  test = true,
  specify = true,
  suite = true,
}

local QUERY = [[
  (call_expression
    function: (_) @fn
    arguments: (arguments . (_) @title)) @call
]]

local MODIFIERS = {
  only = true,
  skip = true,
  each = true,
  todo = true,
  failing = true,
  concurrent = true,
  serial = true,
  parallel = true,
  fixme = true,
}

---@param text string
---@return string|nil keyword, string|nil modifier
local function parse_callee(text)
  local keyword, rest = text:match '^([%a_]+)(.*)$'
  if not keyword or not KEYWORDS[keyword] then
    return nil
  end
  if rest == '' then
    return keyword, nil
  end
  local modifier = rest:match '^%.([%a_]+)$'
  if modifier and MODIFIERS[modifier] then
    return keyword, modifier
  end
  return nil
end

---@param text string
local function clean_title(text)
  local title = text
  -- Strip a single layer of surrounding quotes/backticks
  local quote = title:sub(1, 1)
  if quote == '"' or quote == "'" or quote == '`' then
    title = title:sub(2, -2)
  end
  title = title:gsub('%${', '{'):gsub('%s+', ' ')
  return vim.trim(title)
end

---@param bufnr integer
---@return table[]
function M.collect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return {}
  end

  local lang = parser:lang()
  local query_ok, query = pcall(vim.treesitter.query.parse, lang, QUERY)
  if not query_ok then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end

  local raw = {}
  for _, match in query:iter_matches(tree:root(), bufnr, 0, -1, { all = true }) do
    local nodes = {}
    for id, list in pairs(match) do
      nodes[query.captures[id]] = type(list) == 'table' and list[1] or list
    end

    if nodes.fn and nodes.title and nodes.call then
      local keyword, modifier = parse_callee(vim.treesitter.get_node_text(nodes.fn, bufnr))
      if keyword then
        local start_row, start_col, end_row = nodes.call:range()
        table.insert(raw, {
          keyword = keyword,
          modifier = modifier,
          title = clean_title(vim.treesitter.get_node_text(nodes.title, bufnr)),
          row = start_row + 1,
          col = start_col,
          end_row = end_row + 1,
        })
      end
    end
  end

  table.sort(raw, function(a, b)
    if a.row ~= b.row then
      return a.row < b.row
    end
    return a.col < b.col
  end)

  local lnum_width = 0
  for _, entry in ipairs(raw) do
    lnum_width = math.max(lnum_width, #tostring(entry.row))
  end

  local items = {}
  local stack = {}
  for _, entry in ipairs(raw) do
    while #stack > 0 and stack[#stack].end_row < entry.row do
      table.remove(stack)
    end

    local depth = #stack
    local label = entry.keyword .. (entry.modifier and ('.' .. entry.modifier) or '')
    local lnum_text = string.format('%' .. lnum_width .. 'd', entry.row)

    local ancestors = {}
    for _, parent in ipairs(stack) do
      table.insert(ancestors, parent.title)
    end

    table.insert(items, {
      -- Tree view (no query): indented hierarchy
      tree_text = string.format('%s  %s%s %s', lnum_text, string.rep('  ', depth), label, entry.title),
      lnum_text = lnum_text,
      lnum_width = #lnum_text,
      label = label,
      title = entry.title,
      ancestors = ancestors,
      path = vim.api.nvim_buf_get_name(bufnr),
      bufnr = bufnr,
      lnum = entry.row,
      col = entry.col + 1,
    })

    table.insert(stack, { end_row = entry.end_row, title = entry.title })
  end

  -- Matching always uses the full path, so parent titles stay searchable even
  -- when the displayed context is truncated
  for _, item in ipairs(items) do
    local parts = vim.list_extend({}, item.ancestors)
    table.insert(parts, item.title)
    item.text = string.format('%s  %s %s', item.lnum_text, item.label, table.concat(parts, ' ‹ '))
  end

  return items
end

local outline_ns = vim.api.nvim_create_namespace 'MiniPickTestOutline'

---@param text string
---@param width integer
local function truncate(text, width)
  if width <= 0 then
    return ''
  end
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  return vim.fn.strcharpart(text, 0, math.max(0, width - 1)) .. '…'
end

local function get_available_width(buf_id)
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win_id) == buf_id then
      return vim.api.nvim_win_get_width(win_id) - 1
    end
  end
  return vim.o.columns - 4
end

-- Leaf title comes first, ancestors follow in reverse (closest parent first) so
-- the meaningful part is never the piece that overflows
local function flat_display(item, width)
  local head = string.format('%s  %s %s', item.lnum_text, item.label, item.title)
  if #item.ancestors == 0 then
    return truncate(head, width), #head
  end

  local reversed = {}
  for i = #item.ancestors, 1, -1 do
    table.insert(reversed, item.ancestors[i])
  end
  local context = '  ‹ ' .. table.concat(reversed, ' ‹ ')

  local head_width = vim.fn.strdisplaywidth(head)
  if head_width >= width then
    return truncate(head, width), #head
  end
  return head .. truncate(context, width - head_width), #head
end

M._flat_display = flat_display

local function outline_show(buf_id, items, query, opts)
  local filtering = #query > 0
  local width = get_available_width(buf_id)

  local display, context_starts = {}, {}
  for i, item in ipairs(items) do
    local text = item.tree_text
    if filtering then
      text, context_starts[i] = flat_display(item, width)
    end
    display[i] = vim.tbl_extend('force', item, { text = text })
  end
  require('mini.pick').default_show(buf_id, display, query, opts)

  for i, item in ipairs(items) do
    vim.api.nvim_buf_set_extmark(buf_id, outline_ns, i - 1, 0, {
      end_row = i - 1,
      end_col = item.lnum_width,
      hl_group = 'MiniPickGrepLnum',
      hl_mode = 'combine',
      priority = 200,
    })

    local context_start = context_starts[i]
    if context_start and #display[i].text > context_start then
      vim.api.nvim_buf_set_extmark(buf_id, outline_ns, i - 1, context_start, {
        end_row = i - 1,
        end_col = #display[i].text,
        hl_group = 'MiniPickGrepFile',
        hl_mode = 'combine',
        priority = 199,
      })
    end
  end
end

function M.pick()
  local bufnr = vim.api.nvim_get_current_buf()
  local items = M.collect(bufnr)
  if #items == 0 then
    vim.notify('No test blocks found', vim.log.levels.WARN)
    return
  end

  require('mini.pick').start {
    source = {
      name = 'Test Outline',
      items = items,
      show = outline_show,
      choose = function(item)
        vim.schedule(function()
          vim.api.nvim_set_current_buf(item.bufnr)
          vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
          vim.cmd 'normal! zz'
        end)
      end,
    },
  }
end

return M
