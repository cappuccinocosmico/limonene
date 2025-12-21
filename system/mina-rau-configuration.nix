# NixOS System Configuration for mina-rau
# This file defines what software and settings are installed system-wide.
#
# HELPFUL TIPS FOR BRAD:
# - After making changes, rebuild your system with: sudo nixos-rebuild switch --flake /home/brad/limonene#mina-rau
# - You can also create a shell alias for this (see all-systems.nix)
# - To search for packages: nix search nixpkgs <package-name>
# - NixOS manual: https://nixos.org/manual/nixos/stable/

{ config, pkgs, ... }:

{
  imports = [
    # Hardware configuration - auto-generated during installation
    ./mina-rau-hardware-configuration.nix

    # Common settings for Brad's systems
    ./brad-all-systems.nix
  ];

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================

  # Use systemd-boot as the bootloader (modern UEFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # IMPORTANT: If your system uses disk encryption (LUKS), you'll need to add
  # the encrypted device UUID here. You can find it with:
  # ls -l /dev/disk/by-uuid/
  #
  # Example (uncomment and update the UUID if you have encryption):
  # boot.initrd.luks.devices."luks-YOUR-UUID-HERE".device = "/dev/disk/by-uuid/YOUR-UUID-HERE";

  # ============================================================================
  # NETWORK CONFIGURATION
  # ============================================================================

  # Set the hostname for this computer
  networking.hostName = "mina-rau";

  # ============================================================================
  # LOCALE AND INTERNATIONALIZATION
  # ============================================================================

  # Language and regional settings
  i18n.defaultLocale = "en_US.UTF-8";

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

  # ============================================================================
  # DESKTOP ENVIRONMENT - KDE PLASMA 6 with Wayland
  # ============================================================================

  # Enable X11 support (optional for KDE Plasma 6, but some apps may need it)
  services.xserver.enable = true;

  # Enable SDDM display manager (the login screen for KDE)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;  # Use Wayland for better performance

  # Enable KDE Plasma 6 desktop environment
  services.desktopManager.plasma6.enable = true;

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ============================================================================
  # AUTOMATIC LOGIN (Optional - comment out for more security)
  # ============================================================================

  # Auto-login Brad on boot - REMOVE THESE LINES if you want a login screen
  services.displayManager.autoLogin = {
    enable = true;
    user = "brad";
  };

  # ============================================================================
  # SYSTEM VERSION
  # ============================================================================

  # NixOS state version - DON'T CHANGE THIS after initial installation
  # This ensures compatibility when upgrading NixOS versions
  system.stateVersion = "25.05";
}
