-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  {
      "robitx/gp.nvim",
      config = function()
          local conf = {
              -- For customization, refer to Install > Configuration in the Documentation/Readme
          }
          require("gp").setup(conf)

          -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
          require("which-key").add({
            -- VISUAL mode mappings
            -- s, x, v modes are handled the same way by which_key
            {
                mode = { "v" },
                nowait = true,
                remap = false,
                { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
                { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
                { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split" },
                { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)" },
                { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)" },
                { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New" },
                { "<C-g>g", group = "generate into new .." },
                { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew" },
                { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew" },
                { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup" },
                { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew" },
                { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew" },
                { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
                { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
                { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste" },
                { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite" },
                { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
                { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat" },
                { "<C-g>w", group = "Whisper" },
                { "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", desc = "Whisper Append" },
                { "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
                { "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", desc = "Whisper Enew" },
                { "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", desc = "Whisper New" },
                { "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", desc = "Whisper Popup" },
                { "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
                { "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
                { "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
                { "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", desc = "Whisper" },
                { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext" },
            },

            -- NORMAL mode mappings
            {
                mode = { "n" },
                nowait = true,
                remap = false,
                { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
                { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
                { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
                { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
                { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
                { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
                { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
                { "<C-g>g", group = "generate into new .." },
                { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
                { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
                { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
                { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
                { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
                { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
                { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
                { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
                { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
                { "<C-g>w", group = "Whisper" },
                { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
                { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
                { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
                { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
                { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
                { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
                { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
                { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
                { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
                { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
            },

            -- INSERT mode mappings
            {
                mode = { "i" },
                nowait = true,
                remap = false,
                { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
                { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
                { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
                { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
                { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
                { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
                { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
                { "<C-g>g", group = "generate into new .." },
                { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
                { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
                { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
                { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
                { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
                { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
                { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
                { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
                { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
                { "<C-g>w", group = "Whisper" },
                { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
                { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
                { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
                { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
                { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
                { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
                { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
                { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
                { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
                { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
            },
        })
      end,
  },
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
    'cameron-wags/rainbow_csv.nvim',
    config = true,
    ft = {
        'csv',
        'tsv',
        'csv_semicolon',
        'csv_whitespace',
        'csv_pipe',
        'rfc_csv',
        'rfc_semicolon'
    },
    cmd = {
        'RainbowDelim',
        'RainbowDelimSimple',
        'RainbowDelimQuoted',
        'RainbowMultiDelim'
    }
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
      -- optional for floating window border decoration
      dependencies = {
          "nvim-lua/plenary.nvim",
      },
      -- setting the keybinding for LazyGit with 'keys' is recommended in
      -- order to load the plugin when the command is run for the first time
      keys = {
          { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
      }
  },
  {
    'NvChad/nvim-colorizer.lua',
    config = true
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
