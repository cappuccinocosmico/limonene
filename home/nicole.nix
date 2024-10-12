
# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # Select Window Managers Here:
    wm/sway.nix
    ./packages.nix
    ./fonts.nix
  ];
  home.packages = [ 
    pkgs.dconf 
    # pkgs.nixGL # Necessary for getting sway to run
    pkgs.mesa
    pkgs.libdrm
  ];
  home.sessionVariables = {
   NIXPKGS_ALLOW_UNFREE="1";
   SHELL="/home/nicole/.nix-profile/bin/fish";
  };
  home = {
    username = "nicole";
    homeDirectory = "/home/nicole";
  };


  programs.home-manager.enable = true;
  # Add stuff for your user as you see fit:
  home.sessionVariables = {
    EDITOR = "vi";
    GTK_THEME = "Arc-Dark";
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
    };
  };






  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
