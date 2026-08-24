-- pi-edit: Send visual selection + instructions to pi via RPC mode
-- Pi edits files directly via its tools, then we reload affected buffers.

local M = {}

-- Track active pi jobs
M._active_jobs = {}

-- Configuration
M.config = {
  model = 'anthropic/claude-opus-4-6',
  models = {
    'anthropic/claude-opus-4-6',
    'anthropic/claude-sonnet-4-6',
    'anthropic/claude-sonnet-4-5',
    'anthropic/claude-haiku-4-5',
    'anthropic/claude-opus-4-5',
  },
}

--- Pick the model used for pi edits via vim.ui.select
function M.select_model()
  local items = vim.deepcopy(M.config.models)
  table.insert(items, 'Other…')
  vim.ui.select(items, {
    prompt = 'π Model (current: ' .. M.config.model .. ')',
  }, function(choice)
    if not choice then
      return
    end
    if choice == 'Other…' then
      vim.ui.input({ prompt = 'π Model (provider/id): ', default = M.config.model }, function(input)
        if input and input ~= '' then
          M.config.model = input
          vim.notify('π Model set to ' .. input)
        end
      end)
    else
      M.config.model = choice
      vim.notify('π Model set to ' .. choice)
    end
  end)
end

-- ─── Floating status window ────────────────────────────────────────────────

local spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

local Status = {}
Status.__index = Status

function Status.new(model)
  local self = setmetatable({}, Status)
  self.model = model
  self.start_time = vim.uv.now()
  self.frame = 1
  self.lines = {} -- activity log (most recent last)
  self.max_log = 5
  self.done = false
  self.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[self.buf].bufhidden = 'wipe'
  self.timer = vim.uv.new_timer()
  self.timer:start(0, 100, vim.schedule_wrap(function()
    self.frame = (self.frame % #spinner_frames) + 1
    self:render()
  end))
  return self
end

function Status:log(msg)
  if self.lines[#self.lines] == msg then
    return
  end
  table.insert(self.lines, msg)
  if #self.lines > self.max_log then
    table.remove(self.lines, 1)
  end
  vim.schedule(function()
    self:render()
  end)
end

function Status:render()
  if not (self.buf and vim.api.nvim_buf_is_valid(self.buf)) then
    return
  end

  local elapsed = math.floor((vim.uv.now() - self.start_time) / 1000)
  local header
  if self.done then
    header = string.format('✓ π done · %ds · %s', elapsed, self.model)
  else
    header = string.format('%s π working · %ds · %s', spinner_frames[self.frame], elapsed, self.model)
  end

  local lines = { header }
  for _, l in ipairs(self.lines) do
    table.insert(lines, '  ' .. l)
  end

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(math.max(width + 2, 30), math.floor(vim.o.columns * 0.6))
  local height = #lines

  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)

  local win_config = {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = vim.o.columns - 1,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    zindex = 60,
  }

  if self.win and vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_set_config(self.win, win_config)
  else
    self.win = vim.api.nvim_open_win(self.buf, false, win_config)
    vim.wo[self.win].winhighlight = 'NormalFloat:Normal,FloatBorder:Comment'
  end
end

function Status:finish(msg)
  self.done = true
  if msg then
    self:log(msg)
  end
  vim.schedule(function()
    self:render()
  end)
  -- Auto-close shortly after finishing
  vim.defer_fn(function()
    self:close()
  end, 2500)
end

function Status:close()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end
  if self.win and vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
  self.win = nil
  if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_delete(self.buf, { force = true })
  end
  self.buf = nil
end

-- Namespace for selection highlights
local ns = vim.api.nvim_create_namespace 'pi_edit'
-- Namespace for change flashes
local flash_ns = vim.api.nvim_create_namespace 'pi_edit_flash'

-- Fallback highlight groups (themes can override these)
vim.api.nvim_set_hl(0, 'PiEditActive', { default = true, link = 'Visual' })
vim.api.nvim_set_hl(0, 'PiEditFlash', { default = true, link = 'DiffAdd' })

--- Add highlight to the selected range, returns a cleanup function.
--- The highlight persists for the whole pi run; cleanup() clears it.
local function highlight_selection(bufnr, start_line, end_line)
  for line = start_line - 1, end_line - 1 do
    vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, { line_hl_group = 'PiEditActive' })
  end

  -- Return cleanup function
  return function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
  end
end

--- Flash lines that changed between old_lines and the buffer's current content
local function flash_changes(buf, old_lines)
  local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local old_text = table.concat(old_lines, '\n') .. '\n'
  local new_text = table.concat(new_lines, '\n') .. '\n'
  if old_text == new_text then
    return false
  end

  local diff_fn = (vim.text and vim.text.diff) or vim.diff
  local ok, hunks = pcall(diff_fn, old_text, new_text, { result_type = 'indices' })
  if not ok or type(hunks) ~= 'table' then
    return false
  end

  local flashed = false
  for _, h in ipairs(hunks) do
    local start_b, count_b = h[3], h[4]
    -- Pure deletion (count_b == 0): flash the line at the deletion point
    local first = math.max(count_b == 0 and start_b or start_b, 1)
    local last = count_b == 0 and first or (start_b + count_b - 1)
    for line = first - 1, math.min(last, #new_lines) - 1 do
      pcall(vim.api.nvim_buf_set_extmark, buf, flash_ns, line, 0, { line_hl_group = 'PiEditFlash' })
      flashed = true
    end
  end

  if flashed then
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_clear_namespace(buf, flash_ns, 0, -1)
      end
    end, 1800)
  end
  return flashed
end

--- Build the prompt message from selection context + user instructions
local function build_prompt(filepath, start_line, end_line, filetype, selected_text, instructions)
  local range_str = start_line == end_line and ('line ' .. start_line) or ('lines ' .. start_line .. '-' .. end_line)
  return string.format(
    '%s\n\nIn `%s` (%s, %s):\n\n```%s\n%s\n```',
    instructions,
    filepath,
    range_str,
    filetype,
    filetype,
    selected_text
  )
end

--- Reload any open buffers whose files may have been modified,
--- flashing lines that changed on reload.
local function reload_modified_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= '' then
      local old_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      vim.api.nvim_buf_call(buf, function()
        vim.cmd 'silent! checktime'
      end)
      flash_changes(buf, old_lines)
    end
  end
end

--- Parse a JSONL line safely
local function parse_json(line)
  if not line or line == '' then
    return nil
  end
  local ok, data = pcall(vim.json.decode, line)
  if ok and type(data) == 'table' then
    return data
  end
  return nil
end

--- Create a stateful line reader for unbuffered job stdout.
--- Neovim delivers partial lines: data[1] continues the previous chunk's
--- last element, and data[#data] may be incomplete. This joins them so
--- callers always receive complete lines.
local function make_line_reader()
  local partial = ''
  return function(data)
    if not data or #data == 0 then
      return {}
    end
    data[1] = partial .. data[1]
    partial = table.remove(data)
    return data
  end
end

--- Send a JSON command to the pi RPC process
local function rpc_send(job_id, cmd)
  local json_line = vim.json.encode(cmd) .. '\n'
  vim.fn.chansend(job_id, json_line)
end

--- Run pi in RPC mode with the given prompt
--- @param prompt string
--- @param cwd string
--- @param cleanup function|nil  Called on completion/error to clear highlights
function M.run(prompt, cwd, cleanup)
  local job_id
  local tool_name = nil
  local tool_args = nil
  local text_chunks = {}
  local read_lines = make_line_reader()

  local status = Status.new(M.config.model)

  local function notify(msg, level)
    level = level or vim.log.levels.INFO
    vim.schedule(function()
      vim.notify(msg, level)
    end)
  end

  local finished = false
  local function finish(final_msg)
    if cleanup then
      vim.schedule(cleanup)
      cleanup = nil -- only call once
    end
    if not finished then
      finished = true
      status:finish(final_msg)
    end
  end

  status:log 'starting pi…'

  job_id = vim.fn.jobstart({ 'pi', '--mode', 'rpc', '--no-session', '--model', M.config.model }, {
    cwd = cwd,
    stdin = 'pipe',
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      for _, line in ipairs(read_lines(data)) do
        local event = parse_json(line)
        if not event then
          goto continue
        end

        if event.type == 'tool_execution_start' then
          tool_name = event.toolName
          tool_args = event.args
          if tool_name == 'edit' and tool_args and tool_args.path then
            status:log('edit  ' .. vim.fn.fnamemodify(tool_args.path, ':~:.'))
          elseif tool_name == 'write' and tool_args and tool_args.path then
            status:log('write ' .. vim.fn.fnamemodify(tool_args.path, ':~:.'))
          elseif tool_name == 'bash' and tool_args and tool_args.command then
            status:log('bash  ' .. tool_args.command:sub(1, 50))
          elseif tool_name == 'read' and tool_args and tool_args.path then
            status:log('read  ' .. vim.fn.fnamemodify(tool_args.path, ':~:.'))
          elseif tool_name then
            status:log(tool_name)
          end
        end

        if event.type == 'tool_execution_end' then
          if event.isError then
            status:log('⚠ tool error: ' .. (event.toolName or '?'))
          end
        end

        if event.type == 'message_start' then
          status:log 'thinking…'
        end

        if event.type == 'message_update' then
          local delta = event.assistantMessageEvent
          if delta and delta.type == 'text_delta' then
            table.insert(text_chunks, delta.delta)
          end
        end

        if event.type == 'agent_end' then
          vim.schedule(function()
            reload_modified_buffers()
            -- reload_modified_buffers triggers FileChangedShellPost which clears highlights
            -- but call finish() as a safety net
            finish 'done'
          end)
        end

        if event.type == 'response' and event.command == 'prompt' and not event.success then
          finish('✗ ' .. (event.error or 'unknown error'))
          notify('π Error: ' .. (event.error or 'unknown'), vim.log.levels.ERROR)
        end

        ::continue::
      end
    end,
    on_stderr = function(_, data, _)
      for _, line in ipairs(data) do
        if line and line ~= '' then
          notify('π stderr: ' .. line, vim.log.levels.WARN)
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      M._active_jobs[job_id] = nil
      if exit_code ~= 0 then
        finish('✗ exited with code ' .. exit_code)
        notify('π Process exited with code ' .. exit_code, vim.log.levels.WARN)
      else
        finish()
      end
    end,
  })

  if job_id <= 0 then
    finish '✗ failed to start pi'
    notify('π Failed to start pi process', vim.log.levels.ERROR)
    return
  end

  M._active_jobs[job_id] = true

  vim.defer_fn(function()
    rpc_send(job_id, {
      type = 'prompt',
      message = prompt,
    })
  end, 500)
end

--- Send selection to pi running in a sibling wezterm pane
function M.send_to_pane()
  -- Get selected lines
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local selected_text = table.concat(lines, '\n')

  -- File info
  local filepath = vim.fn.expand '%:p'
  local filetype = vim.bo.filetype

  -- Find pi pane in same tab
  local my_pane = os.getenv 'WEZTERM_PANE'
  if not my_pane then
    vim.notify('WEZTERM_PANE not set — not running in wezterm?', vim.log.levels.ERROR)
    return
  end

  local json_str = vim.fn.system 'wezterm cli list --format json'
  local ok, panes = pcall(vim.json.decode, json_str)
  if not ok then
    vim.notify('Failed to parse wezterm pane list', vim.log.levels.ERROR)
    return
  end

  -- Find our tab_id
  local my_tab_id = nil
  for _, p in ipairs(panes) do
    if tostring(p.pane_id) == my_pane then
      my_tab_id = p.tab_id
      break
    end
  end

  if not my_tab_id then
    vim.notify('Could not find our pane in wezterm list', vim.log.levels.ERROR)
    return
  end

  -- Find pi pane in same tab (title starts with π)
  local pi_pane_id = nil
  for _, p in ipairs(panes) do
    if p.tab_id == my_tab_id and tostring(p.pane_id) ~= my_pane and p.title:match '^π' then
      pi_pane_id = p.pane_id
      break
    end
  end

  -- Build message
  local range_str = start_line == end_line and ('line ' .. start_line) or ('lines ' .. start_line .. '-' .. end_line)
  local msg = string.format('In `%s` (%s, %s):\n\n```%s\n%s\n```\n', filepath, range_str, filetype, filetype,
    selected_text)

  -- Helper to send message and activate pane
  local function send_msg_to_pane(pane_id)
    -- Clear existing editor content first (Ctrl+C = app.clear in pi)
    local clear_cmd = string.format('wezterm cli send-text --pane-id %d --no-paste', pane_id)
    vim.fn.system(clear_cmd, '\x03')

    -- Send to pi pane (no trailing newline — let user review before pressing enter)
    local cmd = string.format('wezterm cli send-text --pane-id %d --no-paste', pane_id)
    vim.fn.system(cmd, msg)

    -- Activate the pi pane
    vim.fn.system(string.format('wezterm cli activate-pane --pane-id %d', pane_id))
  end

  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)

  if pi_pane_id then
    send_msg_to_pane(pi_pane_id)
    vim.notify('Sent to pi pane ' .. pi_pane_id)
  else
    -- No pi pane found — spawn one in a right split
    local cwd = vim.fn.getcwd()
    local new_pane_id = vim.fn.system(string.format(
      'wezterm cli split-pane --right --percent 50 --cwd %s -- pi',
      vim.fn.shellescape(cwd)
    ))
    new_pane_id = vim.trim(new_pane_id)
    local pane_num = tonumber(new_pane_id)
    if not pane_num then
      vim.notify('Failed to spawn pi pane', vim.log.levels.ERROR)
      return
    end
    -- Poll until pi is ready, then send the message
    local attempts = 0
    local max_attempts = 40 -- 40 x 100ms = 4s max
    local function try_send()
      attempts = attempts + 1
      local text = vim.fn.system(string.format('wezterm cli get-text --pane-id %d', pane_num))
      if text:find('pi>') or text:find('❯') then
        send_msg_to_pane(pane_num)
        vim.notify('Spawned pi pane ' .. pane_num .. ' and sent message')
      elseif attempts < max_attempts then
        vim.defer_fn(try_send, 100)
      else
        -- Timeout — send anyway as a fallback
        send_msg_to_pane(pane_num)
        vim.notify('Spawned pi pane ' .. pane_num .. ' (sent after timeout)', vim.log.levels.WARN)
      end
    end
    vim.defer_fn(try_send, 200)
  end
end

--- Entry point: capture selection, prompt for instructions, run pi
function M.edit_selection()
  local in_visual = vim.fn.mode():match '^[vV\22]' ~= nil

  -- Capture selection bounds: visual selection, or current line in normal mode
  local start_line, end_line
  if in_visual then
    start_line = vim.fn.line 'v'
    end_line = vim.fn.line '.'
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  else
    start_line = vim.fn.line '.'
    end_line = start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local selected_text = table.concat(lines, '\n')
  local filepath = vim.fn.expand '%:p'
  local filetype = vim.bo.filetype
  local cwd = vim.fn.getcwd()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Exit visual mode synchronously
  if in_visual then
    vim.cmd 'normal! \27'
  end

  -- Defer the input prompt to next event loop tick so the mode switch settles
  vim.schedule(function()
    vim.ui.input({ prompt = 'π Instructions: ' }, function(instructions)
      if not instructions or instructions == '' then
        vim.notify('π Cancelled', vim.log.levels.WARN)
        return
      end

      -- Highlight the selection while pi works
      local cleanup = highlight_selection(bufnr, start_line, end_line)

      local prompt = build_prompt(filepath, start_line, end_line, filetype, selected_text, instructions)
      M.run(prompt, cwd, cleanup)
    end)
  end)
end

return M
