-- pi-edit: Send visual selection + instructions to pi via RPC mode
-- Pi edits files directly via its tools, then we reload affected buffers.

local M = {}

-- Track active pi jobs
M._active_jobs = {}

-- Namespace for selection highlights
local ns = vim.api.nvim_create_namespace 'pi_edit'

--- Add highlight to the selected range, returns a cleanup function
local function highlight_selection(bufnr, start_line, end_line)
  for line = start_line - 1, end_line - 1 do
    vim.api.nvim_buf_add_highlight(bufnr, ns, 'PiEditActive', line, 0, -1)
  end

  -- Watch for buffer changes to auto-clear
  local autocmd_id
  autocmd_id = vim.api.nvim_create_autocmd({ 'BufModifiedSet', 'FileChangedShellPost', 'BufReadPost' }, {
    buffer = bufnr,
    callback = function()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      pcall(vim.api.nvim_del_autocmd, autocmd_id)
    end,
  })

  -- Return cleanup function
  return function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    pcall(vim.api.nvim_del_autocmd, autocmd_id)
  end
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

--- Reload any open buffers whose files may have been modified
local function reload_modified_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= '' then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd 'silent! checktime'
      end)
    end
  end
end

--- Parse a JSONL line safely
local function parse_json(line)
  if not line or line == '' then
    return nil
  end
  local ok, data = pcall(vim.json.decode, line)
  if ok then
    return data
  end
  return nil
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

  local function notify(msg, level)
    level = level or vim.log.levels.INFO
    vim.schedule(function()
      vim.notify(msg, level)
    end)
  end

  local function finish()
    if cleanup then
      vim.schedule(cleanup)
      cleanup = nil -- only call once
    end
  end

  notify('π Starting pi edit…')

  job_id = vim.fn.jobstart({ 'pi', '--mode', 'rpc', '--no-session' }, {
    cwd = cwd,
    stdin = 'pipe',
    stdout_buffered = false,
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        local event = parse_json(line)
        if not event then
          goto continue
        end

        if event.type == 'tool_execution_start' then
          tool_name = event.toolName
          tool_args = event.args
          if tool_name == 'edit' and tool_args and tool_args.path then
            notify('π Editing ' .. vim.fn.fnamemodify(tool_args.path, ':~:.'))
          elseif tool_name == 'write' and tool_args and tool_args.path then
            notify('π Writing ' .. vim.fn.fnamemodify(tool_args.path, ':~:.'))
          elseif tool_name == 'bash' and tool_args and tool_args.command then
            notify('π Running: ' .. tool_args.command:sub(1, 60))
          elseif tool_name == 'read' and tool_args and tool_args.path then
            notify('π Reading ' .. vim.fn.fnamemodify(tool_args.path, ':~:.'))
          end
        end

        if event.type == 'tool_execution_end' then
          if event.isError then
            notify('π Tool error: ' .. (event.toolName or '?'), vim.log.levels.WARN)
          end
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
            finish()
            notify('π Done', vim.log.levels.INFO)
          end)
        end

        if event.type == 'response' and event.command == 'prompt' and not event.success then
          finish()
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
      finish()
      if exit_code ~= 0 then
        notify('π Process exited with code ' .. exit_code, vim.log.levels.WARN)
      end
    end,
  })

  if job_id <= 0 then
    finish()
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

--- Entry point: capture selection, prompt for instructions, run pi
function M.edit_selection()
  -- Capture selection bounds while still in visual mode
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local selected_text = table.concat(lines, '\n')
  local filepath = vim.fn.expand '%:p'
  local filetype = vim.bo.filetype
  local cwd = vim.fn.getcwd()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Exit visual mode synchronously
  vim.cmd 'normal! \27'

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
