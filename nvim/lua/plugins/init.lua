return {
  'onsails/lspkind.nvim',
  'easymotion/vim-easymotion',
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  { 'tris203/precognition.nvim', opts = {} }, -- assists with discovering motions
  {
    'sphamba/smear-cursor.nvim',
    opts = {
      -- Smear cursor color. Defaults to Cursor GUI color if not set.
      -- Set to "none" to match the text color at the target cursor position.
      cursor_color = '#AD8F17',
      -- Background color. Defaults to Normal GUI background color if not set.
      normal_bg = '#1C2E41',
    },
  }, -- cursor animation
}
