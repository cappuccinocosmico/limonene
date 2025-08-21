# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # Select Window Managers Here:
    wm/sway.nix
    # wm/hyprland.nix

    ./packages.nix
    ./fonts.nix
    inputs.nixvim.homeModules.nixvim
  ];
  home.packages = [ 

    pkgs.nix-ld
    pkgs.dconf 
    # pkgs.nixGL # Necessary for getting sway to run
    pkgs.mesa
    pkgs.libdrm
  ];
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE="1";
    SHELL="/home/nicole/.nix-profile/bin/fish";
    GTK_THEME = "Arc-Dark";
    # EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "foot";
    PNPM_HOME = "$HOME/.binaries/pnpm";
  };
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.binaries/pnpm"
  ];

  # qt.enable = true;
  # qt.style.name = "adwaita-dark";
  # gtk.enable = true;
  # gtk.theme.name = "Adwaita-dark";
  # programs.dconf.enable = true;
  home = {
    username = "nicole";
    homeDirectory = "/home/nicole";
  };


  programs.home-manager.enable = true;
  # Add stuff for your user as you see fit:

  home.sessionVariables = {
  };
  # XDG Everything
  xdg={
    systemDirs.data = ["${pkgs.gsettings-desktop-schemas}/share"];
    # Default user directories
    userDirs={
      enable = true;
      createDirectories = true;
      music = "${config.home.homeDirectory}/Music";
      download = "${config.home.homeDirectory}/Downloads";
      documents = "${config.home.homeDirectory}/Documents";
      publicShare = "${config.home.homeDirectory}/Documents/public";
      templates = null;
    };
  };
  programs= {
    # Enable home-manager and git
    git={
      enable = true;
      lfs.enable = false; # Very scary
      userName = "Nicole Venner";
      userEmail = "nvenner@protonmail.ch";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };
  nix.extraOptions="
    experimental-features = nix-command flakes
  ";
  # allowUnfree = true



  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";

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
