{
  lib,
  config,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;

  # Build sops.nvim plugin
  sops-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "sops-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "trixnz";
      repo = "sops.nvim";
      rev = "main";
      hash = "sha256-6BFgZSQwrh218genHjnldv1xnCjx4PIoXZcFYKVBlGo=";
    };
  };

  # Build neopywal.nvim — reads wallust palette and applies it as the colorscheme
  neopywal-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "neopywal-nvim";
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "RedsXDD";
      repo = "neopywal.nvim";
      rev = "09188d79b45694141ec779d05cbcc75f994639d1";
      hash = "sha256-RLwxyGRmU1B8r6xO1YObF8qlNEj7qitNUArUlw092V8=";
    };
  };

  # Build wpm.nvim — typing speed feedback while writing
  wpm-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "wpm-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "shasherazi";
      repo = "wpm-nvim";
      rev = "main";
      hash = "sha256-di235c3d1P2p2wEdLnf0KbSGfLceljKDoCQekzkR9aA=";
    };
  };
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
      ./nvim-extra.lua
    ];

    # Theme — managed by neopywal which reads wallust colors directly
    theme = {
      enable = false;
    };

    # Language support with LSP, formatting, and autocomplete
    languages = {
      go = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format.enable = true;
      };

      rust = {
        enable = true;
        lsp = {
          enable = true;
          package = ["rust-analyzer"];
        };
        treesitter.enable = true;
        format.enable = true;
        extensions.crates-nvim.enable = true;
      };

      nix = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
        format.enable = true;
      };

      wgsl = {
        enable = true;
        lsp.enable = true;
        treesitter.enable = true;
      };

      openscad = {
        enable = true;
        lsp.enable = true;
      };

      typescript = {
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
      presets.harper.enable = true;
      lightbulb.enable = true;
      lspSignature.enable = true;
      lspkind.enable = true;
      otter-nvim.enable = true;
      trouble.enable = true;
    };

    autocomplete = {
      nvim-cmp = {
        enable = true;
      };
    };

    # Vim options
    options = {
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      autoread = true;
      exrc = true;
      foldlevelstart = 99;
    };

    # Treesitter
    treesitter = {
      enable = true;
      fold = true;
      grammars = [pkgs.tree-sitter-grammars.tree-sitter-openscad];
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

    # Additional plugins
    extraPlugins = {
      mini-comment = {
        package = pkgs.vimPlugins.mini-nvim;
        setup = "require('mini.comment').setup()";
      };

      mini-surround = {
        package = pkgs.vimPlugins.mini-nvim;
        setup = "require('mini.surround').setup()";
      };

      luasnip = {
        package = pkgs.vimPlugins.luasnip;
        setup = "require('luasnip').setup()";
      };

      grug-far = {
        package = pkgs.vimPlugins.grug-far-nvim;
        setup = ''
          require('grug-far').setup({
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

      sops-nvim = {
        package = sops-nvim;
      };

      lean-nvim = {
        package = pkgs.vimPlugins.lean-nvim;
        setup = ''
          require('lean').setup({
            mappings = true,
            infoview = {
              autoopen = true,
            },
          })
        '';
      };

      neopywal = {
        package = neopywal-nvim;
        setup = ''
          require('neopywal').setup({
            use_palette = { dark = "wallust", light = "wallust" },
            transparent_background = true,
          })
          vim.cmd('colorscheme neopywal')
        '';
      };

      wpm = {
        package = wpm-nvim;
        setup = ''
          require('wpm').setup()
        '';
      };

      # aw-watcher-nvim = {
      #   package = pkgs.vimPlugins.aw-watcher-nvim;
      #   setup = ''
      #     require('aw_watcher').setup({
      #       host = "127.0.0.1",
      #       port = 5600,
      #     })
      #   '';
      # };
    };

    # Autocommands
    autocmds = [
      {
        event = ["FocusGained"];
        pattern = ["*"];
        callback = lib.generators.mkLuaInline ''
          function()
            vim.cmd("colorscheme neopywal")
          end
        '';
      }

      {
        event = ["FocusGained" "BufEnter" "CursorHold" "CursorHoldI"];
        pattern = ["*"];
        callback = lib.generators.mkLuaInline ''
          function()
            if vim.fn.mode() ~= "c" then
              vim.cmd("checktime")
            end
          end
        '';
      }

      {
        event = ["FileChangedShellPost"];
        pattern = ["*"];
        callback = lib.generators.mkLuaInline ''
          function()
            vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
          end
        '';
      }

      {
        event = ["FileType"];
        pattern = ["markdown" "md"];
        callback = lib.generators.mkLuaInline ''
          function()
            vim.opt_local.spell = true
            vim.opt_local.spelllang = "en_us"
          end
        '';
      }

      {
        event = ["ColorScheme"];
        pattern = ["*"];
        callback = lib.generators.mkLuaInline ''
          function()
            vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#ec9d7a", bold = true })
          end
        '';
      }
    ];

    luaConfigRC.dashboard-header-color = ''
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#ec9d7a", bold = true })
    '';

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

    # Key mappings
    maps = {
      normal = {
        "<leader>e" = {
          action = ":lua Snacks.explorer()<CR>";
          desc = "Toggle file explorer";
        };

        "<leader>g" = {
          action = ":lua Snacks.lazygit()<CR>";
          desc = "Open lazygit";
        };

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

        "<C-s>" = {
          action = ":w<CR>";
          desc = "Save file";
        };

        "<leader>sr" = {
          action = ":lua require('grug-far').open()<CR>";
          desc = "Search and replace";
        };
      };

      insert = {
        "<C-s>" = {
          action = "<ESC>:w<CR>";
          desc = "Save file and exit insert mode";
        };
      };

      visual = {
        "<C-s>" = {
          action = "<ESC>:w<CR>";
          desc = "Save file and exit visual mode";
        };
      };
    };
  };
}
