{ inputs, lib, config, pkgs, ... }: {
  programs.nixvim = {
    enable = true;
    imports = [
      ../nvim/keymaps.nix
      ../nvim/treesitter.nix
      ../nvim/toggleterm.nix
      ../nvim/themes.nix
      ../nvim/lazygit.nix
      ../nvim/lualine.nix
      ../nvim/dashboard.nix
      ../nvim/bufferline.nix
      ../nvim/snacks.nix
      ../nvim/gitsigns.nix
      ../nvim/whichkey.nix
      ../nvim/hlchunk.nix
      ../nvim/yanky.nix
      ../nvim/autopairs.nix
      ../nvim/blink-cmp.nix
      ../nvim/tmux-navigator.nix
      ../nvim/smear-cursor.nix
      ../nvim/lsp/conform.nix
      ../nvim/lsp/fidget.nix
      ../nvim/lsp/lsp.nix
      ../nvim/nix-develop.nix
      ../nvim/kulala.nix
      ../nvim/aerial.nix
      ../nvim/autosave.nix
      ../nvim/notify.nix
      ../nvim/barbecue.nix
      ../nvim/noice.nix
      ../nvim/neoscroll.nix
      ../nvim/markview.nix
      ../nvim/zen-mode.nix
      ../nvim/yazi.nix
      ../nvim/wtf.nix
      # ../nvim/windsurf-vim.nix if you want to use this plugin uncomment it and run nix develop --impure
      ../nvim/ts-comments.nix
      ../nvim/timerly.nix
      ../nvim/treesj.nix
      ../nvim/web-devicons.nix
    ];
    globals = {
      mapleader = " ";
    };
    opts = {
      number = true;
      colorcolumn = "80";
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      wrap = false;
      swapfile = false; # Undotree
      backup = false; # Undotree
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      foldlevelstart = 99;
    };
    extraPackages = with pkgs; [
      # base
      nerd-fonts.jetbrains-mono # Font
      fzf
      ripgrep
      fd
      # Formatters
      stylua # Lua formatter
      csharpier # C# formatter
      nixfmt-rfc-style # Nix formatter
      # Linters
      golangci-lint # Go linter
      shellcheck # Shell script linter
      eslint_d # JavaScript/TypeScript linter
      # Debuggers
      netcoredbg # C# debugger
      asm-lsp # Assembly LSP
      # bashdb # Bash debugger
      delve # Go debugger
    ];
  };
}
