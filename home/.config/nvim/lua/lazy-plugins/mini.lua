local setup_starter = function()
  local header = [[
        ║╲  ║
        ║ ╲ ║
        ║  ╲║

     N E O V I M
  ]]
  local footer = [[]]

  local items = nil

  local starter = require 'mini.starter'

  items = {
    starter.sections.recent_files(10, true, false),
  }

  starter.setup {
    header = header,
    footer = footer,
    items = items,
  }
end

return {
  'nvim-mini/mini.nvim',
  version = false,
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    {

      'dmtrKovalenko/fff.nvim',
      build = function()
        -- this will download prebuild binary or try to use existing rustup toolchain to build from source
        -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
        require('fff.download').download_or_build_binary()
      end,
    },
  },
  config = function()
    if not vim.g.vscode then
      setup_starter()
    end

    local hipatterns = require 'mini.hipatterns'

    hipatterns.setup {
      highlighters = {
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        fixme2 = { pattern = '%f[%w]()fixme()%f[%W]', group = 'MiniHipatternsFixme' },
        todo = {
          pattern = '%f[%w]()TODO()%f[%W]',
          group = 'MiniHipatternsTodo',
        },
        todo2 = {
          pattern = '%f[%w]()todo()%f[%W]',
          group = 'MiniHipatternsTodo',
        },
        note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    -- Better Around/Inside textobjects
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    local ai = require 'mini.ai'

    require('mini.jump').setup()
    local ui = require 'lib.ui'

    require('mini.bufremove').setup()
    require('mini.cmdline').setup()

    require('mini.files').setup {
      mappings = {
        go_in = 'l',
        go_out = 'h',
        synchronize = '=',
      },
      windows = {
        max_number = 2,
        preview = false,
      },
    }

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        vim.keymap.set('n', '<CR>', function()
          MiniFiles.go_in { close_on_file = true }
        end, { buffer = buf_id, desc = 'Go in and close' })
        vim.keymap.set('n', '-', MiniFiles.go_out, { buffer = buf_id, desc = 'Go out' })
        vim.keymap.set('n', '<leader>w', MiniFiles.synchronize, { buffer = buf_id, desc = 'Save filesystem changes' })

        local map_split = function(lhs, direction, desc)
          vim.keymap.set('n', lhs, function()
            local entry = MiniFiles.get_fs_entry()
            if entry == nil or entry.fs_type == 'directory' then
              return
            end
            MiniFiles.close()
            vim.cmd(direction .. ' ' .. vim.fn.fnameescape(entry.path))
          end, { buffer = buf_id, desc = desc })
        end

        map_split('<C-s>', 'split', 'Open in horizontal split')
        map_split('<C-v>', 'vsplit', 'Open in vertical split')
        map_split('<C-t>', 'tabedit', 'Open in new tab')
      end,
    })

    vim.keymap.set('n', '_', function()
      MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, { desc = 'Open mini.files (current file)' })

    vim.keymap.set('n', '-', function()
      MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, { desc = 'Open mini.files (current file)' })

    require('mini.notify').setup {
      lsp_progress = { enable = false },
      window = {
        config = function()
          return {
            border = ui.border_chars_empty,
            anchor = 'SE',
            col = vim.o.columns,
            row = vim.o.lines - vim.o.cmdheight - 2,
          }
        end,
      },
    }

    vim.keymap.set('n', '<leader>xn', MiniNotify.clear, { desc = 'Dismiss Notifications' })

    require('mini.extra').setup()

    require('mini.pick').setup {
      mappings = {
        mark_all = '<C-S-x>',
        choose_marked = '<C-q>',
      },
      source = {
        choose_marked = function(items)
          -- If nothing is marked, send all matched items to quickfix
          if #items == 0 then
            items = MiniPick.get_picker_matches().all or {}
          end
          MiniPick.default_choose_marked(items)
        end,
      },
      window = {
        config = function()
          return {
            border = ui.border_chars_empty,
            width = vim.o.columns < 120 and vim.o.columns or nil,
          }
        end,
      },
    }

    -- fff.nvim frecency file picker
    require('mini.icons').setup()
    local fff_state = {}

    local function fff_find(query)
      local file_picker = require 'fff.file_picker'
      query = query or ''
      local results = file_picker.search_files(query, fff_state.current_file_cache, 100, 4)
      local cwd = vim.uv.cwd()

      local items = {}
      for _, item in ipairs(results) do
        table.insert(items, {
          text = item.relative_path,
          path = cwd .. '/' .. item.relative_path,
          score = item.total_frecency_score,
        })
      end
      return items
    end

    local fff_ns = vim.api.nvim_create_namespace 'MiniPickFFF'

    local function fff_show(buf_id, items)
      local lines = {}
      local icon_data = {}

      for i, item in ipairs(items) do
        local icon, hl = MiniIcons.get('file', item.text)
        icon_data[i] = { icon = icon, hl = hl }
        lines[i] = string.format('%s %s', icon, item.text)
      end

      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      vim.api.nvim_buf_clear_namespace(buf_id, fff_ns, 0, -1)

      for i, _ in ipairs(items) do
        vim.api.nvim_buf_set_extmark(buf_id, fff_ns, i - 1, 0, {
          end_row = i - 1,
          end_col = #icon_data[i].icon,
          hl_group = icon_data[i].hl,
          hl_mode = 'combine',
          priority = 200,
        })
      end
    end

    local grep_ns = vim.api.nvim_create_namespace 'MiniPickGrep'

    local function grep_show(buf_id, items)
      local lines = {}
      local regions = {}

      for i, item in ipairs(items) do
        local text = item.text or tostring(item)
        lines[i] = text
        -- Parse "filename:lnum: content" pattern
        local fname_end = text:find ':%d'
        if fname_end then
          local lnum_start = fname_end
          local lnum_end = text:find(':', lnum_start + 1)
          regions[i] = {
            fname = { 0, fname_end - 1 },
            lnum = { lnum_start - 1, lnum_end and lnum_end or #text },
          }
        end
      end

      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      vim.api.nvim_buf_clear_namespace(buf_id, grep_ns, 0, -1)

      for i, region in pairs(regions) do
        -- Filename in blue
        vim.api.nvim_buf_set_extmark(buf_id, grep_ns, i - 1, region.fname[1], {
          end_row = i - 1,
          end_col = region.fname[2],
          hl_group = 'MiniPickGrepFile',
          hl_mode = 'combine',
          priority = 200,
        })
        -- Line number in gray
        vim.api.nvim_buf_set_extmark(buf_id, grep_ns, i - 1, region.lnum[1], {
          end_row = i - 1,
          end_col = region.lnum[2],
          hl_group = 'MiniPickGrepLnum',
          hl_mode = 'combine',
          priority = 200,
        })
      end
    end

    local function fff_pick()
      local file_picker = require 'fff.file_picker'
      if not file_picker.is_initialized() then
        if not file_picker.setup() then
          vim.notify('Could not setup fff.nvim', vim.log.levels.ERROR)
          return
        end
      end
      -- Rescan to pick up files created externally (e.g. by an LLM agent)
      file_picker.scan_files()

      local current_buf = vim.api.nvim_get_current_buf()
      if current_buf and vim.api.nvim_buf_is_valid(current_buf) then
        local current_file = vim.api.nvim_buf_get_name(current_buf)
        if current_file ~= '' and vim.fn.filereadable(current_file) == 1 then
          fff_state.current_file_cache = vim.fs.relpath(vim.uv.cwd(), current_file)
        else
          fff_state.current_file_cache = nil
        end
      end

      MiniPick.start {
        source = {
          name = 'Files (fff)',
          items = fff_find,
          match = function(_, _, query)
            local items = fff_find(table.concat(query))
            MiniPick.set_picker_items(items, { do_match = false })
          end,
          show = fff_show,
        },
        window = vim.o.columns >= 120 and {
          config = { width = 80 },
        } or nil,
      }

      fff_state.current_file_cache = nil
    end

    MiniPick.registry.fffiles = fff_pick

    vim.keymap.set('n', '<leader><space>', fff_pick, { desc = 'Find Files (fff)' })
    -- fff.nvim live grep picker
    local function fff_grep_find(query)
      local grep = require 'fff.grep'
      query = query or ''
      if query == '' then
        return {}
      end
      local grep_mode = 'plain'
      if query:sub(1, 1) == '/' then
        grep_mode = 'regex'
        query = query:sub(2)
      end
      if query == '' then
        return {}
      end
      local result = grep.search(query, 0, 200, nil, grep_mode)
      local items = {}
      for _, item in ipairs(result.items or {}) do
        local file = item.relative_path or ''
        local fname = vim.fn.fnamemodify(file, ':t')
        local lnum = item.line_number or 0
        local col = (item.col or 0)
        local content = item.line_content or ''
        local abs_path = vim.uv.cwd() .. '/' .. file
        if type(content) ~= 'string' then
          content = tostring(content) or ''
        end
        table.insert(items, {
          text = string.format('%s:%d: %s', fname, lnum, vim.trim(content)),
          path = abs_path,
          lnum = lnum,
          col = col,
        })
      end
      return items
    end

    local function fff_grep_pick()
      local file_picker = require 'fff.file_picker'
      if not file_picker.is_initialized() then
        if not file_picker.setup() then
          vim.notify('Could not setup fff.nvim', vim.log.levels.ERROR)
          return
        end
      end
      -- Rescan to pick up files created externally (e.g. by an LLM agent)
      file_picker.scan_files()

      MiniPick.start {
        source = {
          name = 'Grep (fff)',
          items = {},
          match = function(_, _, query)
            local items = fff_grep_find(table.concat(query))
            MiniPick.set_picker_items(items, { do_match = false })
          end,
          show = grep_show,
          choose = function(item)
            vim.schedule(function()
              vim.cmd('edit ' .. vim.fn.fnameescape(item.path))
              vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
            end)
          end,
        },
      }
    end

    MiniPick.registry.ffgrep = fff_grep_pick

    vim.keymap.set('n', '<leader>sg', fff_grep_pick, { desc = 'Live Grep (fff)' })
    vim.keymap.set('n', '<leader>,', MiniPick.builtin.buffers, { desc = 'Buffers' })
    vim.keymap.set('n', '<leader>sr', MiniPick.builtin.resume, { desc = 'Resume Pick' })
    vim.keymap.set('n', '<leader>sw', function()
      MiniPick.builtin.grep { pattern = vim.fn.expand '<cword>' }
    end, { desc = 'Search Word Under Cursor' })

    vim.keymap.set('n', '<leader>sm', function()
      local marks = {}
      -- Collect lowercase (buffer-local) and uppercase (global) marks
      for _, mark_char in ipairs(vim.split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '')) do
        local pos = vim.api.nvim_get_mark(mark_char, {})
        local row, col, buf, file = pos[1], pos[2], pos[3], pos[4]
        if row ~= 0 then
          local line_text = ''
          if file ~= '' then
            -- Global mark: try to get line from file
            local bufnr = vim.fn.bufnr(file)
            if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
              local lines = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
              line_text = lines[1] or ''
            else
              line_text = file
            end
          else
            -- Local mark
            local lines = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
            line_text = lines[1] or ''
          end
          local display = string.format('%s  %4d:%d  %s', mark_char, row, col, vim.trim(line_text))
          table.insert(marks, {
            text = display,
            mark = mark_char,
            row = row,
            col = col,
            file = file,
          })
        end
      end

      MiniPick.start {
        source = {
          name = 'Marks',
          items = marks,
          choose = function(item)
            if item.file ~= '' then
              vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
            end
            vim.api.nvim_win_set_cursor(0, { item.row, item.col })
          end,
        },
      }
    end, { desc = 'Search Marks' })

    vim.keymap.set('n', '<leader>sh', MiniPick.builtin.help, { desc = 'Search Help' })

    vim.keymap.set('n', '<leader>sH', function()
      local items = {}
      local hl_list = vim.api.nvim_get_hl(0, {})
      for name, hl in pairs(hl_list) do
        local parts = {}
        if hl.fg then
          table.insert(parts, string.format('fg=#%06x', hl.fg))
        end
        if hl.bg then
          table.insert(parts, string.format('bg=#%06x', hl.bg))
        end
        if hl.link then
          table.insert(parts, 'link=' .. hl.link)
        end
        if hl.bold then
          table.insert(parts, 'bold')
        end
        if hl.italic then
          table.insert(parts, 'italic')
        end
        if hl.underline then
          table.insert(parts, 'underline')
        end
        local detail = #parts > 0 and table.concat(parts, ' ') or '(empty)'
        table.insert(items, {
          text = string.format('%-40s %s', name, detail),
          hl_name = name,
        })
      end
      table.sort(items, function(a, b)
        return a.hl_name < b.hl_name
      end)

      MiniPick.start {
        source = {
          name = 'Highlights',
          items = items,
          choose = function(item)
            vim.cmd('highlight ' .. item.hl_name)
          end,
        },
      }
    end, { desc = 'Search Highlights' })

    vim.keymap.set('n', '<leader>sk', function()
      local items = {}
      for _, mode in ipairs { 'n', 'i', 'v', 'x', 's', 'o', 'c', 't' } do
        local maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(maps) do
          local desc = map.desc or ''
          local rhs = map.rhs or (map.callback and '<callback>') or ''
          table.insert(items, {
            text = string.format('%-4s %-30s %-30s %s', mode, map.lhs, rhs, desc),
            mode = mode,
            lhs = map.lhs,
          })
        end
      end
      table.sort(items, function(a, b)
        return a.text < b.text
      end)

      MiniPick.start {
        source = {
          name = 'Keymaps',
          items = items,
          choose = function(item)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(item.lhs, true, true, true), item.mode, false)
          end,
        },
      }
    end, { desc = 'Search Keymaps' })

    vim.keymap.set('n', '<leader>ss', function()
      local kind_names = vim.lsp.protocol.SymbolKind
      local function flatten_symbols(symbols, prefix, bufnr, result)
        result = result or {}
        prefix = prefix or ''
        for _, sym in ipairs(symbols) do
          local name = prefix ~= '' and (prefix .. ' > ' .. sym.name) or sym.name
          local kind = kind_names[sym.kind] or tostring(sym.kind)
          local row = sym.selectionRange.start.line + 1
          local col = sym.selectionRange.start.character
          local left = string.format('%s:%d', name, row)
          local pad = math.max(1, 58 - #left - #kind)
          table.insert(result, {
            text = left .. string.rep(' ', pad) .. kind,
            row = row,
            col = col,
            bufnr = bufnr,
          })
          if sym.children then
            flatten_symbols(sym.children, name, bufnr, result)
          end
        end
        return result
      end

      local bufnr = vim.api.nvim_get_current_buf()
      local params = { textDocument = vim.lsp.util.make_text_document_params() }
      vim.lsp.buf_request(bufnr, 'textDocument/documentSymbol', params, function(err, result)
        if err or not result or #result == 0 then
          vim.notify('No symbols found', vim.log.levels.WARN)
          return
        end
        local items = flatten_symbols(result, '', bufnr)
        vim.schedule(function()
          MiniPick.start {
            source = {
              name = 'LSP Symbols',
              items = items,
              choose = function(item)
                vim.schedule(function()
                  vim.api.nvim_set_current_buf(item.bufnr)
                  vim.api.nvim_win_set_cursor(0, { item.row, item.col })
                end)
              end,
            },
          }
        end)
      end)
    end, { desc = 'LSP Document Symbols' })

    ai.setup {
      n_lines = 500,
      -- custom_textobjects = {
      --   f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }, {}),
      --   c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
      --   a = ai.gen_spec.treesitter({ a = '@parameter.outer', i = '@parameter.inner' }, {}),
      --   p = ai.gen_spec.treesitter({ a = '@parameter.list', i = '@parameter.list' }, {}),
      -- },
    }

    -- Move lines
    require('mini.move').setup {
      mappings = {
        -- visual mode
        left = '<S-h>',
        right = '<S-l>',
        down = '<S-j>',
        up = '<S-k>',
        -- normal mode
        line_left = '<S-h>',
        line_right = '<S-l>',
        line_down = '<S-j>',
        line_up = '<S-k>',
      },
    }
    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
  end,
}
