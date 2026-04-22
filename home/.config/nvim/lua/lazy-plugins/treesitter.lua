return { -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    -- On the main branch, nvim-treesitter only manages parser/query installation.
    -- Highlighting, indentation, and folding are handled by Neovim builtins (0.12+).
    config = function()
      require('nvim-treesitter').setup {
        auto_install = true,
      }
      require('nvim-treesitter').install {
        'bash',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'regex',
        'typescript',
        'javascript',
        'tsx',
        'prisma',
      }

      -- Enable treesitter highlighting for all filetypes that have a parser
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      max_lines = 10,
      multiline_threshold = 5,
    },
  },
}
