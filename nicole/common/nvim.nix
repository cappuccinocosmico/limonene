{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  vim = {
    # Basic configuration
    viAlias = false;
    vimAlias = true;

    # Use system clipboard for yank/paste
    clipboard = {
      enable = true;
      registers = "unnamedplus";
      providers = {
        wl-copy.enable = isLinux;
      };
    };

    # Extra Lua configuration files
    extraLuaFiles = [
      ../config/nvim-extra.lua
    ];

    # Theme
    theme = {
      enable = true;
      name = "tokyonight";
      style = "night";
      transparent = true;
    };

    # Language support with LSP, formatting, and autocomplete
    languages = {
      # Go
      go = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format.enable = true;
      };

      # Rust
      rust = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format.enable = true;
        crates.enable = true;
      };

      # TypeScript/JavaScript
      ts = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format = {
          enable = true;
          type = "prettier";
        };
      };

      # Nix
      nix = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format.enable = true;
      };
    };

    # LSP and completion
    lsp = {
      enable = true;
      formatOnSave = true;
      inlayHints.enable = true;
      harper-ls.enable = true;
      lightbulb.enable = true;
      lspSignature.enable = true;
      lspKind.enable = true;
      otter-nvim.enable = true;
      trouble.enable = true;
    };

    autocomplete = {
      nvim-cmp = {
        enable = true;
      };
    };

    # Treesitter
    treesitter = {
      enable = true;
      fold = true;
    };

    # Snacks.nvim utilities including file explorer
    utility = {
      snacks-nvim = {
        enable = true;
        setupOpts = {
          dashboard = {
            preset = {
              header = ''                ▖ ▄▖▖  ▖▄▖▖ ▖▄▖▖ ▖▄▖
                ▌ ▐ ▛▖▞▌▌▌▛▖▌▙▖▛▖▌▙▖
                ▙▖▟▖▌▝ ▌▙▌▌▝▌▙▖▌▝▌▙▖
              '';
              header_hl = "SnacksDashboardHeader";
            };
            sections = [
              {section = "header";}
              {
                section = "keys";
                gap = 0;
                padding = 1;
              }
              {
                section = "recent_files";
                limit = 8;
                padding = 1;
              }
            ];
          };
          explorer = {
            replace_netrw = true;
            trash = true;
          };
          lazygit = {};
          indent = {};
          input = {};
          image = {};
          # Highlight yanked text
          animate = {
            enabled = true;
          };
        };
      };
    };

    # Telescope for fuzzy finding
    telescope = {
      enable = true;
    };

    # Git integration
    git = {
      enable = true;
      gitsigns = {
        enable = true;
      };
    };

    # Additional plugins to match LazyVim functionality
    extraPlugins = {
      # Mini plugins
      mini-comment = {
        package = pkgs.vimPlugins.mini-nvim;
        setup = "require('mini.comment').setup()";
      };

      mini-surround = {
        package = pkgs.vimPlugins.mini-nvim;
        setup = "require('mini.surround').setup()";
      };

      # LuaSnip
      luasnip = {
        package = pkgs.vimPlugins.luasnip;
        setup = "require('luasnip').setup()";
      };

      # grug-far.nvim for search and replace
      grug-far = {
        package = pkgs.vimPlugins.grug-far-nvim;
        setup = ''
          require('grug-far').setup({
            -- Options for automatic detection of root directory
            keymaps = {
              replace = '<localleader>r',
              qflist = '<localleader>q',
              syncLocations = '<localleader>s',
              syncLine = '<localleader>l',
              close = '<localleader>c',
              historyOpen = '<localleader>t',
              historyAdd = '<localleader>a',
              refresh = '<localleader>f',
              gotoLocation = '<enter>',
              pickHistoryEntry = '<enter>',
            },
          })
        '';
      };
    };

    # Which-key for keybind discovery
    binds = {
      whichKey = {
        enable = true;
        setupOpts = {
          preset = "modern";
          win.border = "rounded";
        };
        register = {
          "<leader>f" = "+find";
          "<leader>g" = "+git";
          "<leader>l" = "+lsp";
          "<leader>s" = "+search";
          "<leader>t" = "+toggle";
          "<leader>w" = "+windows";
          "<leader>x" = "+diagnostics";
        };
      };
    };

    # Key mappings and options
    maps = {
      normal = {
        # File explorer
        "<leader>e" = {
          action = ":lua Snacks.explorer()<CR>";
          desc = "Toggle file explorer";
        };

        # Git
        "<leader>g" = {
          action = ":lua Snacks.lazygit()<CR>";
          desc = "Open lazygit";
        };

        # Telescope bindings (LazyVim style)
        "<leader>ff" = {
          action = ":Telescope find_files<CR>";
          desc = "Find files";
        };
        "<leader><leader>" = {
          action = ":Telescope find_files<CR>";
          desc = "Find files";
        };
        "<leader>fg" = {
          action = ":Telescope live_grep<CR>";
          desc = "Live grep";
        };
        "<leader>/" = {
          action = ":Telescope live_grep<CR>";
          desc = "Live grep";
        };
        "<leader>fb" = {
          action = ":Telescope buffers<CR>";
          desc = "Find buffers";
        };
        "<leader>fh" = {
          action = ":Telescope help_tags<CR>";
          desc = "Help tags";
        };
        "<leader>fr" = {
          action = ":Telescope oldfiles<CR>";
          desc = "Recent files";
        };

        # LSP mappings
        "gd" = {
          action = ":Telescope lsp_definitions<CR>";
          desc = "Go to definition";
        };
        "gr" = {
          action = ":Telescope lsp_references<CR>";
          desc = "Go to references";
        };
        "<leader>ca" = {
          action = ":lua vim.lsp.buf.code_action()<CR>";
          desc = "Code actions";
        };
        "<leader>rn" = {
          action = ":lua vim.lsp.buf.rename()<CR>";
          desc = "Rename symbol";
        };

        # Diagnostics
        "<leader>xx" = {
          action = ":Telescope diagnostics<CR>";
          desc = "Show diagnostics";
        };
        "]d" = {
          action = ":lua vim.diagnostic.goto_next()<CR>";
          desc = "Next diagnostic";
        };
        "[d" = {
          action = ":lua vim.diagnostic.goto_prev()<CR>";
          desc = "Previous diagnostic";
        };

        # Application and window management
        "<leader>qq" = {
          action = ":qa!<CR>";
          desc = "Quit application";
        };
        "<leader>wo" = {
          action = ":only<CR>";
          desc = "Close all other windows";
        };
        "<leader>bo" = {
          action = ":%bd|e#|bd#<CR>";
          desc = "Close all other buffers";
        };

        # Save file
        "<C-s>" = {
          action = ":w<CR>";
          desc = "Save file";
        };

        # Grug-far search and replace
        "<leader>sr" = {
          action = ":lua require('grug-far').open()<CR>";
          desc = "Search and replace";
        };
      };

      insert = {
        # Save file and return to normal mode
        "<C-s>" = {
          action = "<ESC>:w<CR>";
          desc = "Save file and exit insert mode";
        };
      };

      visual = {
        # Save file and return to normal mode
        "<C-s>" = {
          action = "<ESC>:w<CR>";
          desc = "Save file and exit visual mode";
        };
      };
    };
  };
}
