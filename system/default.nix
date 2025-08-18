{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # System Modules
    ./services.nix
    # System Pkgs
    ./server-pkgs.nix
    ./nixos-exclusive.nix
  ];
  
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ ];
    loader.efi = {
      canTouchEfiVariables = true;
    };
    loader.systemd-boot = {
      enable = true;
    };
    # Use the GRUB 2 boot loader.
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
      useOSProber = true;
    };
  };
  systemd.extraConfig = ''
  DefaultTimeoutStopSec=10s
  DefaultTimeoutStartSec=10s
  '';
  nixpkgs.config.allowUnfree= true;
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://watersucks.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
      ];
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      # Cache Hyprland so it dosent build all the time
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  programs.nix-ld={
    enable = true;
    libraries = with pkgs; [];
  };
  users.groups.entertain.gid = 4269;
  security.polkit.enable = true;
  programs.kdeconnect= {
    enable = true;
  };
  
  /*
  if test (id --user nicole) -ge 1000 && test (tty) = "/dev/tty1"
    Hyperland | wl-copy
  end */
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  fonts= {
    enableDefaultPackages=true;
    packages = with pkgs;[
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.monofur
    nerd-fonts.victor-mono
    dejavu_fonts
    monocraft
    ];
    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu" ];
      };
    };
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
