
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

services.flatpak.enable = true;
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
};
  environment.systemPackages = with pkgs; [
    nix-ld
    wineWowPackages.waylandFull
    lutris
    heroic
    feather
    devenv
  ];
  services.tailscale.enable = false;
  # Software for bios updates.
  services.fwupd.enable = true;
  programs.nix-ld.enable = true;

  # nixos-cli service
  services.nixos-cli = {
    enable = true;
    config = {
      # You can add specific configuration options here if needed
    };
  };


  # Enable networking
  networking.networkmanager.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
    shell= pkgs.fish;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


}
