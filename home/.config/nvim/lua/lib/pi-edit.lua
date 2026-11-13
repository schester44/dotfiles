-- pi-edit: select text → give instructions → pi works in the background.
--
-- The selected region is tracked with an extmark and locked while pi works.
-- Pi never writes the current file: it returns the new text for the region in
-- <replacement> tags and we splice it into the buffer, so edits you make
-- elsewhere in the buffer meanwhile are preserved. Pi may still create/edit
-- *other* files (research notes, adjacent docs, etc.) with its tools.

local M = {}

M.config = {
  -- openai/* runs on the ChatGPT subscription (pi's openai login), claude-code/*
  -- on the Claude Code subscription. Only some OpenAI models are allowed on a
  -- ChatGPT account (e.g. gpt-5.5 / *-codex are rejected).
  model = 'openai/gpt-6-luna',
  models = {
    'openai/gpt-6-luna', -- fast
    'openai/gpt-6.1-terra', -- balanced
    'openai/gpt-6.1-sol', -- strongest, slower
    'claude-code/claude-haiku-5-5',
    'claude-code/claude-sonnet-5-5',
    'claude-code/claude-opus-5-5',
  },
  context_lines = 30, -- lines of surrounding context sent with the selection
  linger_ms = 2500, -- how long finished jobs stay in the status float
}

---@type table<integer, table> active jobs keyed by job id
M._jobs = {}
local next_id = 0

local ns = vim.api.nvim_create_namespace 'pi_edit'
local flash_ns = vim.api.nvim_create_namespace 'pi_edit_flash'
local lock_group = vim.api.nvim_create_augroup('PiEditLock', { clear = true })

-- Fallback highlight groups (themes can override these)
vim.api.nvim_set_hl(0, 'PiEditActive', { default = true, link = 'Visual' })
vim.api.nvim_set_hl(0, 'PiEditFlash', { default = true, link = 'DiffAdd' })

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = 'π' })
  end)
end

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

-- ─── Status float (one float, one entry per job) ───────────────────────────

local spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local status = { entries = {}, frame = 1 }

local function status_close()
  if status.timer then
    status.timer:stop()
    status.timer:close()
    status.timer = nil
  end
  if status.win and vim.api.nvim_win_is_valid(status.win) then
    vim.api.nvim_win_close(status.win, true)
  end
  if status.buf and vim.api.nvim_buf_is_valid(status.buf) then
    vim.api.nvim_buf_delete(status.buf, { force = true })
  end
  status.win, status.buf = nil, nil
end

local function status_render()
  if #status.entries == 0 then
    status_close()
    return
  end

  local lines = {}
  for _, job in ipairs(status.entries) do
    local elapsed = math.floor(((job.end_time or vim.uv.now()) - job.start_time) / 1000)
    local icon = job.done and (job.ok and '✓' or '✗') or spinner_frames[status.frame]
    table.insert(lines, string.format('%s π %s · %ds · %s', icon, job.label, elapsed, job.model_short))
    if job.activity then
      table.insert(lines, '   ' .. job.activity)
    end
  end

  if not (status.buf and vim.api.nvim_buf_is_valid(status.buf)) then
    status.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[status.buf].bufhidden = 'wipe'
  end
  vim.api.nvim_buf_set_lines(status.buf, 0, -1, false, lines)

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(math.max(width + 2, 30), math.floor(vim.o.columns * 0.6))

  local win_config = {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = vim.o.columns - 1,
    width = width,
    height = #lines,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    zindex = 60,
  }
  if status.win and vim.api.nvim_win_is_valid(status.win) then
    vim.api.nvim_win_set_config(status.win, win_config)
  else
    status.win = vim.api.nvim_open_win(status.buf, false, win_config)
    vim.wo[status.win].winhighlight = 'NormalFloat:Normal,FloatBorder:Comment'
  end
end

local function status_add(job)
  table.insert(status.entries, job)
  if not status.timer then
    status.timer = vim.uv.new_timer()
    status.timer:start(0, 100, vim.schedule_wrap(function()
      status.frame = (status.frame % #spinner_frames) + 1
      status_render()
    end))
  end
end

local function status_remove(job)
  for i, j in ipairs(status.entries) do
    if j == job then
      table.remove(status.entries, i)
      break
    end
  end
  status_render()
end

local function set_activity(job, msg)
  job.activity = msg
end

-- ─── Region tracking & locking ─────────────────────────────────────────────

--- (Re)place the region extmark so it covers `lines` starting at (sr, sc).
--- Start gravity right / end gravity left: text typed exactly at either
--- boundary lands *outside* the region.
local function region_mark(job, sr, sc, lines)
  if job.mark then
    pcall(vim.api.nvim_buf_del_extmark, job.buf, ns, job.mark)
  end
  local er = sr + #lines - 1
  local ec = (#lines == 1 and sc or 0) + #lines[#lines]
  local zero_width = er == sr and ec == sc
  job.mark = vim.api.nvim_buf_set_extmark(job.buf, ns, sr, sc, {
    end_row = er,
    end_col = ec,
    hl_group = 'PiEditActive',
    hl_eol = true,
    -- a zero-width region would invert with outward gravity; keep it closed
    right_gravity = not zero_width,
    end_right_gravity = zero_width,
    priority = 200,
  })
end

--- Region bounds, normalized so start <= end. `inverted` is true when the
--- extmark flipped (the whole region was deleted and replaced in one change);
--- the span between the flipped ends is then the text now in the region.
--- @return integer|nil sr, integer sc, integer er, integer ec, boolean inverted
local function region_get(job)
  if not vim.api.nvim_buf_is_valid(job.buf) then
    return nil
  end
  local m = vim.api.nvim_buf_get_extmark_by_id(job.buf, ns, job.mark, { details = true })
  if not m or #m == 0 then
    return nil
  end
  local sr, sc, er, ec = m[1], m[2], m[3].end_row, m[3].end_col
  if er < sr or (er == sr and ec < sc) then
    return er, ec, sr, sc, true
  end
  return sr, sc, er, ec, false
end

local function region_text(job)
  local sr, sc, er, ec = region_get(job)
  if not sr then
    return nil
  end
  local ok, text = pcall(vim.api.nvim_buf_get_text, job.buf, sr, sc, er, ec, {})
  return ok and text or nil
end

local function region_clear(job)
  if job.mark and vim.api.nvim_buf_is_valid(job.buf) then
    pcall(vim.api.nvim_buf_del_extmark, job.buf, ns, job.mark)
  end
  job.mark = nil
end

local last_lock_notice = 0

--- Undo any edit that touched a locked region.
local function enforce_locks(buf)
  for _, job in pairs(M._jobs) do
    if job.buf == buf and job.mark and not job.lost then
      local cur = region_text(job)
      if not vim.deep_equal(cur, job.original) then
        local sr, sc, er, ec, inverted = region_get(job)
        local restore = job.original
        if inverted and er > sr and ec == 0 then
          -- A whole-line replace leaves the line's newline inside the span; keep it
          restore = vim.list_extend(vim.deepcopy(job.original), { '' })
        end
        local ok = sr ~= nil
          and pcall(function()
            pcall(vim.cmd, 'undojoin')
            vim.api.nvim_buf_set_text(buf, sr, sc, er, ec, restore)
            region_mark(job, sr, sc, job.original)
          end)
        if not ok then
          -- Couldn't restore (region mangled); result will open in a scratch split.
          job.lost = true
          region_clear(job)
        end
        local now = vim.uv.now()
        if now - last_lock_notice > 2000 then
          last_lock_notice = now
          notify('Region is locked while π works on it (<leader>ax to cancel)', vim.log.levels.WARN)
        end
      end
    end
  end
end

local function jobs_in_buf(buf)
  local n = 0
  for _, job in pairs(M._jobs) do
    if job.buf == buf then
      n = n + 1
    end
  end
  return n
end

local function lock_buffer(buf)
  if #vim.api.nvim_get_autocmds { group = lock_group, buffer = buf } > 0 then
    return
  end
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = lock_group,
    buffer = buf,
    callback = function()
      vim.schedule(function()
        enforce_locks(buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd('BufUnload', {
    group = lock_group,
    buffer = buf,
    callback = function()
      for _, job in pairs(M._jobs) do
        if job.buf == buf then
          M.cancel_job(job, 'buffer closed')
        end
      end
    end,
  })
end

local function unlock_buffer_if_idle(buf)
  if jobs_in_buf(buf) == 0 and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_clear_autocmds { group = lock_group, buffer = buf }
  end
end

-- ─── Applying results ──────────────────────────────────────────────────────

local function flash_rows(buf, first, last)
  for row = first, last do
    pcall(vim.api.nvim_buf_set_extmark, buf, flash_ns, row, 0, { line_hl_group = 'PiEditFlash' })
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, flash_ns, 0, -1)
    end
  end, 1800)
end

--- Flash lines that changed between old_lines and the buffer's current content
local function flash_changes(buf, old_lines)
  local new_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local old_text = table.concat(old_lines, '\n') .. '\n'
  local new_text = table.concat(new_lines, '\n') .. '\n'
  if old_text == new_text then
    return
  end
  local diff_fn = (vim.text and vim.text.diff) or vim.diff
  local ok, hunks = pcall(diff_fn, old_text, new_text, { result_type = 'indices' })
  if not ok or type(hunks) ~= 'table' then
    return
  end
  for _, h in ipairs(hunks) do
    local start_b, count_b = h[3], h[4]
    local first = math.max(start_b, 1)
    local last = count_b == 0 and first or (start_b + count_b - 1)
    flash_rows(buf, first - 1, math.min(last, #new_lines) - 1)
  end
end

--- Reload other open buffers pi may have modified on disk.
--- Skips the job's own buffer and any buffer with unsaved changes.
local function reload_other_buffers(skip_buf)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      buf ~= skip_buf
      and vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted
      and not vim.bo[buf].modified
      and vim.api.nvim_buf_get_name(buf) ~= ''
    then
      local old_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      vim.api.nvim_buf_call(buf, function()
        vim.cmd 'silent! checktime'
      end)
      flash_changes(buf, old_lines)
    end
  end
end

--- Extract the last <replacement>…</replacement> block from pi's reply.
local function parse_replacement(text, original)
  if not text then
    return nil
  end
  local found
  for s in text:gmatch '<replacement>(.-)</replacement>' do
    found = s
  end
  if not found then
    return nil
  end
  found = found:gsub('^\n', ''):gsub('\n$', '')
  -- Strip a code fence the model added around the text (unless the selection had one)
  if not (original[1] or ''):match '^%s*```' then
    local inner = found:match '^```[^\n]*\n(.*)\n```$'
    if inner then
      found = inner
    end
  end
  return vim.split(found, '\n', { plain = true })
end

local function open_scratch(job, lines, why)
  vim.cmd 'botright vnew'
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = job.filetype
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  notify(why .. ' — π result opened in a scratch split', vim.log.levels.WARN)
end

--- Splice the replacement into the tracked region. Returns true if applied.
local function apply_replacement(job, new_lines)
  local cur = not job.lost and region_text(job) or nil
  if not vim.deep_equal(cur, job.original) then
    open_scratch(job, new_lines, 'Region changed or was removed')
    return false
  end
  local sr, sc, er, ec = region_get(job)
  vim.api.nvim_buf_set_text(job.buf, sr, sc, er, ec, new_lines)
  flash_rows(job.buf, sr, sr + #new_lines - 1)
  return true
end

local function finish_job(job, reply, err)
  if job.done then
    return
  end
  job.done = true
  job.end_time = vim.uv.now()
  M._jobs[job.id] = nil
  if job.chan and job.chan > 0 then
    pcall(vim.fn.jobstop, job.chan)
  end

  vim.schedule(function()
    if err then
      job.ok = false
      set_activity(job, err)
      if err ~= 'cancelled' then
        local detail = #job.stderr > 0 and ('\n' .. table.concat(job.stderr, '\n')) or ''
        notify('π failed: ' .. err .. detail, vim.log.levels.ERROR)
      end
    else
      job.ok = true
      local replacement = parse_replacement(reply, job.original)
      local summary = {}
      if replacement then
        if apply_replacement(job, replacement) then
          table.insert(summary, 'replaced ' .. #replacement .. ' line(s)')
        end
      end

      reload_other_buffers(job.buf)

      local touched = vim.tbl_keys(job.touched)
      if #touched > 0 then
        table.sort(touched)
        local rel = vim.tbl_map(function(p)
          return vim.fn.fnamemodify(p, ':~:.')
        end, touched)
        table.insert(summary, 'wrote ' .. table.concat(rel, ', '))
        if job.touched[job.filepath] then
          notify('π modified ' .. job.filepath .. ' on disk despite instructions; buffer not reloaded', vim.log.levels.WARN)
        end
      end

      if #summary == 0 then
        -- Nothing changed: pi probably answered or asked something
        local msg = vim.trim((reply or ''):gsub('<replacement>.-</replacement>', ''))
        table.insert(summary, 'no changes')
        if msg ~= '' then
          notify(msg)
        end
      end
      set_activity(job, table.concat(summary, ' · '))
    end

    region_clear(job)
    unlock_buffer_if_idle(job.buf)
    vim.defer_fn(function()
      status_remove(job)
    end, M.config.linger_ms)
  end)
end

function M.cancel_job(job, reason)
  finish_job(job, nil, reason or 'cancelled')
end

-- ─── Running pi ────────────────────────────────────────────────────────────

local PROMPT = [[
You are editing a region of a file the user has open in Neovim. The user keeps working on the rest of the file while you work, and the buffer may contain unsaved changes, so the excerpt below is the source of truth for the region (not the file on disk).

File: %s (%s), %s at the time of the request.

<context_before>
%s
</context_before>
<selection>
%s
</selection>
<context_after>
%s
</context_after>

Instructions:
%s

Rules:
- NEVER modify %s with edit/write/bash. The editor applies your change to the selection itself.
- If the selection should change, end your reply with the complete new text for the selection inside <replacement></replacement> tags: raw text, no code fences, matching the file's existing style and indentation. It replaces the selection exactly; never include context_before/context_after text.
- If the task involves other files (research, notes, new documents), use your tools to create or edit them, preferring paths next to %s. Include <replacement> only if the selection itself should also change (e.g. adding links to what you created).
- If the selection should not change, omit <replacement> and briefly say what you did.
- Keep any prose outside the tags short.]]

local function build_prompt(job, before, after, instructions)
  local range = job.start_line == job.end_line and ('line ' .. job.start_line)
    or ('lines ' .. job.start_line .. '-' .. job.end_line)
  return string.format(
    PROMPT,
    job.filepath,
    job.filetype,
    range,
    table.concat(before, '\n'),
    table.concat(job.original, '\n'),
    table.concat(after, '\n'),
    instructions,
    job.filepath,
    job.filepath
  )
end

--- Parse a JSONL line safely
local function parse_json(line)
  if not line or line == '' then
    return nil
  end
  local ok, data = pcall(vim.json.decode, line)
  return ok and type(data) == 'table' and data or nil
end

--- Neovim delivers partial lines on unbuffered stdout; join them.
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

--- Text (or error) of the last assistant message in an agent_end event
--- @return string|nil text, string|nil err
local function final_text(event)
  for i = #(event.messages or {}), 1, -1 do
    local msg = event.messages[i]
    if msg.role == 'assistant' and msg.stopReason == 'error' then
      return nil, msg.errorMessage or 'model error'
    end
    if msg.role == 'assistant' and type(msg.content) == 'table' then
      local parts = {}
      for _, c in ipairs(msg.content) do
        if c.type == 'text' and c.text then
          table.insert(parts, c.text)
        end
      end
      return table.concat(parts)
    end
  end
end

local function handle_event(job, event)
  if event.type == 'tool_execution_start' then
    local name, args = event.toolName, event.args or {}
    if (name == 'edit' or name == 'write') and args.path then
      local abs = vim.fn.fnamemodify(args.path, ':p')
      job.touched[abs] = true
      set_activity(job, name .. '  ' .. vim.fn.fnamemodify(abs, ':~:.'))
    elseif name == 'read' and args.path then
      set_activity(job, 'read  ' .. vim.fn.fnamemodify(args.path, ':~:.'))
    elseif name == 'bash' and args.command then
      set_activity(job, 'bash  ' .. args.command:sub(1, 50))
    elseif name then
      set_activity(job, name)
    end
  elseif event.type == 'tool_execution_end' and event.isError then
    set_activity(job, '⚠ tool error: ' .. (event.toolName or '?'))
  elseif event.type == 'message_start' and event.message and event.message.role == 'assistant' then
    set_activity(job, 'thinking…')
  elseif event.type == 'agent_end' then
    local text, err = final_text(event)
    finish_job(job, text, err)
  elseif event.type == 'response' and event.command == 'prompt' and not event.success then
    finish_job(job, nil, event.error or 'prompt rejected')
  end
end

--- Start a job for rows [sr, er] (0-indexed, inclusive) of buf.
local function start_job(buf, sr, er, instructions)
  for _, other in pairs(M._jobs) do
    if other.buf == buf then
      local osr, _, oer = region_get(other)
      if osr and not (er < osr or sr > oer) then
        vim.notify('π is already working on part of that selection', vim.log.levels.WARN)
        return
      end
    end
  end

  next_id = next_id + 1
  local filepath = vim.api.nvim_buf_get_name(buf)
  local job = {
    id = next_id,
    buf = buf,
    filepath = filepath,
    filetype = vim.bo[buf].filetype,
    start_line = sr + 1,
    end_line = er + 1,
    original = vim.api.nvim_buf_get_lines(buf, sr, er + 1, false),
    model = M.config.model,
    model_short = M.config.model:gsub('^.-/', ''),
    start_time = vim.uv.now(),
    touched = {},
    stderr = {},
    activity = 'starting…',
  }
  job.label = string.format('%s:%d-%d', vim.fn.fnamemodify(filepath, ':t'), job.start_line, job.end_line)

  local ctx = M.config.context_lines
  local before = vim.api.nvim_buf_get_lines(buf, math.max(0, sr - ctx), sr, false)
  local after = vim.api.nvim_buf_get_lines(buf, er + 1, er + 1 + ctx, false)

  region_mark(job, sr, 0, job.original)
  lock_buffer(buf)
  M._jobs[job.id] = job
  status_add(job)

  local read_lines = make_line_reader()
  job.chan = vim.fn.jobstart({ 'pi', '--mode', 'rpc', '--no-session', '--model', job.model }, {
    cwd = vim.fn.getcwd(),
    stdin = 'pipe',
    on_stdout = function(_, data)
      for _, line in ipairs(read_lines(data)) do
        local event = parse_json(line)
        if event then
          handle_event(job, event)
        end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(job.stderr, line)
        end
      end
    end,
    on_exit = function(_, code)
      finish_job(job, nil, 'pi exited with code ' .. code)
    end,
  })

  if job.chan <= 0 then
    finish_job(job, nil, 'failed to start pi')
    return
  end

  vim.fn.chansend(job.chan, vim.json.encode {
    type = 'prompt',
    message = build_prompt(job, before, after, instructions),
  } .. '\n')
end

-- ─── Public entry points ───────────────────────────────────────────────────

--- Capture selection (or current line), prompt for instructions, run pi
function M.edit_selection()
  local in_visual = vim.fn.mode():match '^[vV\22]' ~= nil
  local start_line, end_line = vim.fn.line '.', vim.fn.line '.'
  if in_visual then
    start_line = vim.fn.line 'v'
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    vim.cmd 'normal! \27'
  end
  local buf = vim.api.nvim_get_current_buf()

  vim.schedule(function()
    vim.ui.input({ prompt = 'π Instructions: ' }, function(instructions)
      if not instructions or vim.trim(instructions) == '' then
        return
      end
      start_job(buf, start_line - 1, end_line - 1, instructions)
    end)
  end)
end

--- Cancel the job under the cursor, the only running job, or pick one
function M.cancel()
  local jobs = vim.tbl_values(M._jobs)
  if #jobs == 0 then
    vim.notify('π: nothing running')
    return
  end
  local buf, row = vim.api.nvim_get_current_buf(), vim.fn.line '.' - 1
  for _, job in ipairs(jobs) do
    local sr, _, er = region_get(job)
    if job.buf == buf and sr and row >= sr and row <= er then
      return M.cancel_job(job)
    end
  end
  if #jobs == 1 then
    return M.cancel_job(jobs[1])
  end
  vim.ui.select(jobs, {
    prompt = 'π Cancel which job?',
    format_item = function(job)
      return job.label .. ' · ' .. (job.activity or '')
    end,
  }, function(job)
    if job then
      M.cancel_job(job)
    end
  end)
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('PiEditCleanup', { clear = true }),
  callback = function()
    for _, job in pairs(M._jobs) do
      pcall(vim.fn.jobstop, job.chan)
    end
  end,
})

return M
