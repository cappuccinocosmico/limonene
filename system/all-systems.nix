# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  nicole_ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBfMZjr6H4oK3qSBTxjZrMZptWXdzYC6QV4bdS892Ls nicole@vermissian"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1tyFv2UbkAJMx2U6bp8OwRx5wMpK7/DxSslcPS0sWY nicole@incarnadine"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBQresTdgx3Se26QxvwD/S9SaCRCWL8dvZwZ6IM62b2 nicole@cheddar"
  ];
in {
  users.users.nicole = {
    openssh.authorizedKeys.keys = nicole_ssh_keys;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  environment.shellAliases = {
    nrs = ''sudo nixos-rebuild switch --flake /home/nicole/limonene'';
    nrb = ''nixos-rebuild build --verbose --flake /home/nicole/limonene'';
  };
  services.flatpak.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  environment.systemPackages = with pkgs; [
    fwupd
    stress
    phoronix-test-suite

    yggdrasil
    python314
    postgresql_17
    nix-ld
    wineWowPackages.waylandFull
    # lutris
    heroic
    feather
    devenv
    gnome-disk-utility
    git
  ];
  # Software for bios updates.
  services.fwupd.enable = true;
  programs.nix-ld.enable = true;

  virtualisation.docker = {
    enable = true;
  };
  services.tailscale = {
    enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable= true;
  hardware.enableAllFirmware = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [80 443 8080 8443]; # don’t globally allow ssh
    extraCommands = ''
      # Allow RFC1918 IPv4 ranges
      iptables -A INPUT -p tcp --dport 22 -s 192.168.0.0/16 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
      iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/12 -j ACCEPT

      # Block all other SSH attempts
      iptables -A INPUT -p tcp --dport 22 -j DROP
    '';
  };

  # Set your time zone.
  time.timeZone = "America/Denver";
  services.gnome.gnome-keyring.enable = true;

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.getty = {
    autologinUser = "nicole";
    autologinOnce = true;
  };
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.fish.enable = true;
  users.users.nicole = {
    isNormalUser = true;
    description = "Nicole";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.fish;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.trusted-users = ["root" "nicole"];
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };
}
