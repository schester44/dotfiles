return {
  {

    'ravitemer/mcphub.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    cmd = 'MCPHub',
    build = 'npm install -g mcp-hub@latest',
    config = function()
      vim.g.mcphub_auto_approve = true

      require('mcphub').setup {
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          },
        },
      }
    end,
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false,
    config = function()
      require('avante').setup {
        -- these are provided by mcphub
        disabled_tools = {
          -- 'list_files',
          -- 'search_files',
          -- 'read_file',
          -- 'create_file',
          -- 'rename_file',
          -- 'delete_file',
          -- 'create_dir',
          -- 'rename_dir',
          -- 'delete_dir',
          -- 'bash',
        },
        behaviour = {
          -- try disabling cursor_planning_mode if you have issues
          enable_cursor_planning_mode = true,
          auto_apply_diff_after_generation = true,
        },
        provider = 'claude',
        providers = {
          claude = {
            endpoint = 'https://api.anthropic.com',
            model = 'claude-3-7-sonnet-20250219',
            timeout = 30000,
            extra_request_body = {
              temperature = 0,
              max_tokens = 8192,
            },
          },
        },
        selector = {
          provider = 'snacks',
        },

        system_prompt = function()
          local hub = require('mcphub').get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ''
        end,
        custom_tools = function()
          return {
            require('mcphub.extensions.avante').mcp_tool(),
          }
        end,
      }
    end,
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'nvim-tree/nvim-web-devicons',
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },
  },
}
