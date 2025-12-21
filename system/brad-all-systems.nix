# Common System Configuration for Brad's Machines
#
# This file contains settings that are shared across all of Brad's NixOS systems.
# It's similar to Nicole's all-systems.nix but configured for Brad.
#
# WHAT'S IN THIS FILE:
# - User account configuration (Brad)
# - SSH access and security
# - Common system packages (Steam, Docker, development tools)
# - Audio/video/printing services
# - Network configuration
# - Shell configuration (Fish shell)
#
# HOW TO ADD SOFTWARE:
# 1. System-wide packages go in the environment.systemPackages section below
# 2. User-specific packages go in your home-manager config (others/brad/brad.nix)
# 3. To search for packages: nix search nixpkgs <package-name>

{
  config,
  pkgs,
  ...
}: let
  # SSH public keys for Brad (add your SSH keys here for remote access)
  # Generate a key with: ssh-keygen -t ed25519
  # Then add the public key (~/.ssh/id_ed25519.pub) to this list
  brad_ssh_keys = [
    # Add Brad's SSH public keys here, for example:
    # "ssh-ed25519 AAAAC3Nza... brad@mina-rau"
  ];
in {
  # ============================================================================
  # USER CONFIGURATION
  # ============================================================================

  # Configure Brad's user account
  users.users.brad = {
    isNormalUser = true;
    description = "Brad";
    extraGroups = [
      "networkmanager"  # Allows managing network connections
      "wheel"           # Allows using sudo for admin tasks
      "docker"          # Allows using Docker without sudo
    ];
    shell = pkgs.fish;  # Use Fish shell (friendly, modern shell)

    # SSH authorized keys (for remote access)
    openssh.authorizedKeys.keys = brad_ssh_keys;
  };

  # ============================================================================
  # SSH SERVER CONFIGURATION
  # ============================================================================

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;  # Only allow key-based auth (more secure)
  };

  # ============================================================================
  # SHELL ALIASES (Shortcuts)
  # ============================================================================
  # These create convenient shortcuts for common commands

  environment.shellAliases = {
    # Rebuild the system after making changes to config files
    nrs = ''sudo nixos-rebuild switch --flake /home/brad/limonene'';

    # Build the system without switching to it (for testing)
    nrb = ''nixos-rebuild build --verbose --flake /home/brad/limonene'';
  };

  # ============================================================================
  # SYSTEM SERVICES
  # ============================================================================

  # Flatpak support (alternative package manager for GUI apps)
  services.flatpak.enable = true;

  # Steam gaming platform
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Docker for containers
  virtualisation.docker = {
    enable = true;
  };

  # Tailscale VPN for secure remote access
  services.tailscale = {
    enable = true;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Printing support
  services.printing.enable = true;

  # GNOME Keyring for password management
  services.gnome.gnome-keyring.enable = true;

  # ============================================================================
  # AUDIO CONFIGURATION
  # ============================================================================

  # Use PipeWire for audio (modern, low-latency audio system)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  # Software available to all users on the system
  #
  # TO ADD A PACKAGE:
  # 1. Search for it: nix search nixpkgs <package-name>
  # 2. Add it to the list below
  # 3. Rebuild with: sudo nixos-rebuild switch --flake /home/brad/limonene#mina-rau

  environment.systemPackages = with pkgs; [
    # System utilities
    fwupd                       # Firmware update tool
    stress                      # System stress testing
    phoronix-test-suite         # Benchmark suite
    gnome-disk-utility          # Disk management GUI

    # Networking
    yggdrasil                   # Mesh network
    networkmanager              # Network management
    nettools                    # Network utilities

    # Programming languages and tools
    python314                   # Python programming language
    postgresql_17               # PostgreSQL database
    git                         # Version control
    gcc                         # C/C++ compiler
    openssl_3                   # SSL/TLS library

    # Development tools
    nix-ld                      # Run non-NixOS binaries
    devenv                      # Development environments

    # Gaming and entertainment
    wineWowPackages.waylandFull # Run Windows apps/games
    heroic                      # Epic Games launcher
    feather                     # Monero wallet

    # Build tools
    libclang
    pkg-config
    openssl
  ];

  # ============================================================================
  # NETWORK CONFIGURATION
  # ============================================================================

  # Enable NetworkManager for easy network management
  networking.networkmanager.enable = true;

  # Enable all firmware (including proprietary)
  hardware.enableAllFirmware = true;

  # Use latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Firewall configuration (currently disabled - consider enabling for security)
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [80 443 8080 8443];
    # SSH is restricted to local networks only
    extraCommands = ''
      # Allow RFC1918 IPv4 ranges
      iptables -A INPUT -p tcp --dport 22 -s 192.168.0.0/16 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/12 -j ACCEPT

      # Block all other SSH attempts
      iptables -A INPUT -p tcp --dport 22 -j DROP
    '';
  };

  # ============================================================================
  # TIMEZONE AND LOCALE
  # ============================================================================

  # Set your time zone (change this to your local timezone)
  time.timeZone = "America/Denver";

  # ============================================================================
  # SHELL CONFIGURATION
  # ============================================================================

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Enable screen brightness control
  programs.light.enable = true;

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================

  # Allow proprietary software (needed for Steam, Spotify, etc.)
  nixpkgs.config.allowUnfree = true;

  # Allow certain insecure packages (sometimes needed for compatibility)
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  # Nix package manager settings
  nix = {
    settings.trusted-users = ["root" "brad"];
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };
}
