# Linux home-manager configuration for nicole
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Cross-platform configuration
    ./common.nix

    # Linux-specific window manager
    wm/sway.nix

    # Linux-specific packages
    linux/desktop-essentials.nix
    linux/gaming.nix
    linux/music.nix
  ];

  # Linux-specific packages
  home.packages = with pkgs; [
    nix-ld
    dconf
    mesa
    libdrm

    # Linux-specific CLI tools (from server-essentials)
    otel-desktop-viewer
    otel-cli
    imv
    libsixel
    pciutils
    parted
    exfat
    pavucontrol
    helvum
    xterm
    networkmanager
    nettools
    mkp224o

    # Linux-specific dev tools
    steam-run
    dbeaver-bin
  ];

  # Linux-specific shell aliases
  home.shellAliases = {
    nziina = ''eval "if set -q ZELLIJ; exit; else; eval (ssh-agent -c); /home/nicole/Documents/mycorrhizae/ziina/ziina -l 0.0.0.0:2222; end"'';
    ziina-sshget = ''set -x XDG_RUNTIME_DIR /run/user/1000 && set -x WAYLAND_DISPLAY wayland-1 && echo "ssh -p 2222 $ZELLIJ_SESSION_NAME@apiarist" | tee /dev/tty | wl-copy'';
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    SHELL = "${pkgs.fish}/bin/fish";
    GTK_THEME = "Arc-Dark";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    PNPM_HOME = "$HOME/.binaries/pnpm";
  };

  home.sessionPath = [
    "$HOME/.binaries/pnpm"
  ];

  home = {
    username = "nicole";
    homeDirectory = "/home/nicole";
  };

  # XDG directories (Linux-specific)
  xdg = {
    systemDirs.data = ["${pkgs.gsettings-desktop-schemas}/share"];
    userDirs = {
      enable = true;
      createDirectories = true;
      music = "${config.home.homeDirectory}/Music";
      download = "${config.home.homeDirectory}/Downloads";
      documents = "${config.home.homeDirectory}/Documents";
      publicShare = "${config.home.homeDirectory}/Documents/public";
      templates = null;
    };
  };

  programs = {
    firefox.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
