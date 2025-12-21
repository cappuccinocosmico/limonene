# Home Manager Configuration for Brad
#
# This file configures your personal user environment (separate from system-wide config).
# Home Manager manages things like:
# - Shell configuration (fish, bash, zsh)
# - Terminal emulator (kitty)
# - Text editor (neovim)
# - Git settings
# - Application configurations
# - User-specific packages
#
# HELPFUL TIPS:
# - After making changes, rebuild with: sudo nixos-rebuild switch --flake /home/brad/limonene#mina-rau
# - The system will automatically apply your home-manager changes too
# - To search for packages: nix search nixpkgs <package-name>
# - Home Manager manual: https://nix-community.github.io/home-manager/

{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Import common configurations (shell, neovim, CLI tools, git, kitty, fonts)
    ./common.nix

    # Import Linux-specific packages and configurations from Nicole's setup
    # Since Brad only uses Linux, we don't need to separate this out
    ../../nicole/linux/desktop-essentials.nix  # Basic desktop apps (Firefox, file manager, etc.)
    ../../nicole/linux/gaming.nix              # Steam and gaming-related packages
    ../../nicole/linux/music.nix               # Music production and playback software
  ];

  # ============================================================================
  # USER-SPECIFIC PACKAGES
  # ============================================================================
  # Add any extra packages you want here!
  # To search for packages, use: nix search nixpkgs <package-name>
  #
  # Examples of popular packages:
  # - Discord: pkgs.discord
  # - Spotify: pkgs.spotify
  # - LibreOffice: pkgs.libreoffice
  # - GIMP: pkgs.gimp
  # - Blender: pkgs.blender
  # - VLC: pkgs.vlc
  # - OBS Studio: pkgs.obs-studio
  # - Thunderbird: pkgs.thunderbird

  home.packages = with pkgs; [
    # Linux-specific development tools
    nodejs_25      # JavaScript/Node.js runtime
    nix-ld         # Run unpatched binaries on NixOS
    dconf          # Configuration database (used by many apps)
    mesa           # OpenGL implementation
    libdrm         # Direct Rendering Manager

    # CLI tools
    otel-desktop-viewer  # OpenTelemetry viewer
    otel-cli             # OpenTelemetry CLI
    imv                  # Image viewer for Wayland
    libsixel             # Graphics in terminal
    pciutils             # PCI device utilities (lspci)
    parted               # Disk partitioning tool
    exfat                # exFAT filesystem support
    pavucontrol          # PulseAudio volume control (GUI)
    helvum               # Patchbay for PipeWire (audio routing)
    xterm                # Terminal emulator
    networkmanager       # Network management tools
    nettools             # Network utilities (ifconfig, netstat)

    # Development tools
    steam-run      # Run non-NixOS binaries
    dbeaver-bin    # Database management tool

    # ========================================================================
    # ADD YOUR OWN PACKAGES BELOW THIS LINE
    # ========================================================================
    # Uncomment the ones you want or add your own!

    # discord       # Voice/text chat
    # spotify       # Music streaming
    # vlc           # Media player
    # libreoffice   # Office suite
    # gimp          # Image editor
    # inkscape      # Vector graphics editor
    # obs-studio    # Screen recording/streaming
    # thunderbird   # Email client
  ];

  # ============================================================================
  # SHELL ALIASES
  # ============================================================================
  # Shortcuts you can type in the terminal
  # For example, typing "ll" will run "ls -la"

  home.shellAliases = {
    # Add your own custom aliases here!
    # Examples:
    # ll = "ls -la";
    # gs = "git status";
    # update = "sudo nixos-rebuild switch --flake /home/brad/limonene#mina-rau";
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================
  # These variables are available in all your shell sessions

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";           # Allow proprietary software
    SHELL = "${pkgs.fish}/bin/fish";      # Default shell
    GTK_THEME = "Arc-Dark";               # Dark theme for GTK apps
    BROWSER = "firefox";                  # Default web browser
    TERMINAL = "kitty";                   # Default terminal emulator
    PNPM_HOME = "$HOME/.binaries/pnpm";   # PNPM package manager location
  };

  # ============================================================================
  # PATH CONFIGURATION
  # ============================================================================
  # Directories to add to your PATH (for finding executables)

  home.sessionPath = [
    "$HOME/.binaries/pnpm"
  ];

  # ============================================================================
  # USER INFO
  # ============================================================================
  # Your username and home directory

  home = {
    username = "brad";
    homeDirectory = "/home/brad";
  };

  # ============================================================================
  # XDG DIRECTORIES
  # ============================================================================
  # Standard directories for organizing your files

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

  # ============================================================================
  # APPLICATIONS
  # ============================================================================
  # Configure specific applications here

  programs = {
    firefox.enable = true;  # Enable Firefox browser

    # You can add more program configurations here
    # See: https://nix-community.github.io/home-manager/options.html
  };

  # ============================================================================
  # SYSTEMD USER SERVICES
  # ============================================================================
  # Automatically reload services when rebuilding

  systemd.user.startServices = "sd-switch";

  # ============================================================================
  # STATE VERSION
  # ============================================================================
  # DON'T CHANGE THIS after initial installation
  # It ensures compatibility when upgrading Home Manager

  home.stateVersion = "25.05";
}
