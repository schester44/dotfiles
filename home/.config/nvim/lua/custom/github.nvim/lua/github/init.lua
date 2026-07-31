local M = {}

local subcommands = {}

local function create_pr(title, body)
  local cmd = { 'gh', 'pr', 'create', '--draft', '--title', title, '--body', body }

  vim.notify('Creating draft PR...', vim.log.levels.INFO)

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify('PR creation failed: ' .. (result.stderr or ''), vim.log.levels.ERROR)
      else
        local url = vim.trim(result.stdout or '')
        vim.notify('Draft PR created: ' .. url, vim.log.levels.INFO)
        vim.fn.setreg('+', url)
      end
    end)
  end)
end

local function prompt_body(title)
  vim.ui.input({ prompt = 'PR body: ' }, function(body)
    create_pr(title, body or '')
  end)
end

local function prompt_title_and_body()
  vim.ui.input({ prompt = 'PR title: ' }, function(title)
    if not title or title == '' then
      vim.notify('PR creation cancelled', vim.log.levels.WARN)
      return
    end
    prompt_body(title)
  end)
end

subcommands.create = function(args)
  -- :G create "my title" — skip title prompt
  if args and #args > 0 then
    local title = table.concat(args, ' ')
    prompt_body(title)
  else
    prompt_title_and_body()
  end
end

function M.run(args)
  local subcmd = args.fargs[1]

  if not subcmd then
    vim.notify('Usage: :G <subcommand>\nAvailable: create', vim.log.levels.WARN)
    return
  end

  local fn = subcommands[subcmd]
  if not fn then
    vim.notify('Unknown subcommand: ' .. subcmd .. '\nAvailable: create', vim.log.levels.ERROR)
    return
  end

  local sub_args = vim.list_slice(args.fargs, 2)
  fn(sub_args)
end

function M.complete(_, cmd_line, _)
  local args = vim.split(cmd_line, '%s+')
  if #args <= 2 then
    return vim.tbl_keys(subcommands)
  end
  return {}
end

function M.setup()
  vim.api.nvim_create_user_command('G', M.run, {
    nargs = '+',
    complete = function(...)
      return M.complete(...)
    end,
    desc = 'GitHub commands',
  })
end

return M
