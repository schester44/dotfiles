local handler = function(virtText, lnum, endLnum, width, truncate, ctx)
  local newVirtText = {}
  local suffix = (' 󰘖 %d'):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0

  local diagnostics = require 'lib.diagnostics'

  local diag_counts = {}

  for num = lnum - 1, endLnum - 1 do
    for severity, value in pairs(vim.diagnostic.count(ctx.bufnr, { lnum = num })) do
      diag_counts[severity] = value + (diag_counts[severity] or 0)
    end
  end

  local diagnostics_output = {}

  for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
    if diag_counts[severity] then
      table.insert(diagnostics_output, { string.format(' %s %d', diagnostics.text[severity], diag_counts[severity]), diagnostics.texthl[severity] })
    end
  end

  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)

    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end

  table.insert(newVirtText, { suffix, 'FoldedText' })

  if #diagnostics_output > 0 then
    for _, diag in ipairs(diagnostics_output) do
      table.insert(newVirtText, diag)
    end
  end

  return newVirtText
end

return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  cond = not vim.g.vscode,
  config = function()
    vim.o.foldcolumn = '1' -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

    ---@diagnostic disable-next-line: missing-fields
    require('ufo').setup {
      fold_virt_text_handler = handler,
      provider_selector = function()
        return { 'treesitter', 'indent' }
      end,
    }
  end,
}
