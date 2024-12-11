return {
  'rgroli/other.nvim',
  config = function()
    require('other-nvim').setup {
      mappings = {
        'react',

        -- Obie component patterns
        {
          pattern = '/src/(.*)/.*.tsx$',
          target = '/src/%1/\\(*.container.tsx\\|*.queries.ts\\|*.mutations.ts\\|*.test.tsx\\|*.styles.tsx\\|*.styles.ts\\|index.ts\\|index.tsx\\)',
        },
      },
    }

    vim.keymap.set('n', '<leader>ooo', '<cmd>:Other<CR>', { desc = '[O]pen [O]ther [F]ile ' })
    vim.keymap.set('n', '<leader>oos', '<cmd>:OtherVSplit<CR>', { desc = '[O]pen [O]ther [S]plit File' })
  end,
}