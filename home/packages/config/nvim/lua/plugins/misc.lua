-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  { "nvchad/volt", lazy = true },

  {
  "nvchad/minty",
  cmd = { "Shades", "Huefy" },
  }
  {"ThePrimeagen/vim-be-good"},
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss All Notifications",
      },
    },
    opts = {
      stages = "static",
      timeout = 4000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
  },
  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
      -- you also will likely want nvim-cmp or some completion engine
    },
    -- see details below for full configuration options
    opts = {
      lsp = {
        on_attach = on_attach,
      },
      mappings = true,
    }
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
    visible = true,
    show_hidden_count = true,
    hide_dotfiles = false,
    hide_gitignored = false,
    hide_by_name = {
      -- '.git',
      -- '.DS_Store',
      -- 'thumbs.db',
    },
    never_show = {},
        },
      }
    }
  }
}
