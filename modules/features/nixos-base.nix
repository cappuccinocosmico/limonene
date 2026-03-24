{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

  flake.modules.nixos.base = { config, pkgs, ... }: let
    nicole_ssh_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBfMZjr6H4oK3qSBTxjZrMZptWXdzYC6QV4bdS892Ls nicole@vermissian"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1tyFv2UbkAJMx2U6bp8OwRx5wMpK7/DxSslcPS0sWY nicole@incarnadine"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBQresTdgx3Se26QxvwD/S9SaCRCWL8dvZwZ6IM62b2 nicole@cheddar"
    ];
    brad_ssh_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaOgK4fO5gTB79Infge2b+31VzXnC23lqV7m5NA+xuz bvenner@proton.me"
    ];
  in {
    # Copy flake configuration to /etc/nixos/limonene
    environment.etc."nixos/limonene".source = ../..;

    nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
      inputs.nix-vscode-extensions.overlays.default
      inputs.nur.overlays.default
    ];

    environment.systemPackages = [
      (import ../../helpers/regular-linux-shell.nix { inherit pkgs; })
      pkgs.libclang
      pkgs.pkg-config
      pkgs.openssl
      pkgs.brightnessctl
      pkgs.fwupd
      pkgs.stress
      pkgs.phoronix-test-suite
      pkgs.lutris
      pkgs.winetricks
      pkgs.wineWow64Packages.stable
      pkgs.yggdrasil
      pkgs.python314
      pkgs.postgresql_17
      pkgs.nix-ld
      pkgs.heroic
      pkgs.feather
      pkgs.devenv
      pkgs.gnome-disk-utility
      pkgs.git
      pkgs.gcc
      pkgs.openssl_3
      pkgs.msr-tools
      pkgs.parted
    ];

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.binfmt.registrations."aarch64-linux".fixBinary = true;

    users.users.nicole = {
      isNormalUser = true;
      description = "Nicole";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = nicole_ssh_keys;
    };

    users.users.brad = {
      isNormalUser = true;
      description = "Brad";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = brad_ssh_keys;
    };

    services.throttled.enable = true;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    services.atd.enable = true;
    services.fwupd.enable = true;
    programs.nix-ld.enable = true;

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="serio", KERNEL=="serio0", ATTR{power/wakeup}="disabled"
    '';

    virtualisation.docker.enable = true;
    services.tailscale.enable = true;

    networking.networkmanager.enable = true;
    hardware.enableAllFirmware = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

    networking.firewall = {
      enable = false;
      allowedTCPPorts = [ 80 443 8080 8443 ];
      extraCommands = ''
        iptables -A INPUT -p tcp --dport 22 -s 192.168.0.0/16 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/12 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -j DROP
      '';
    };

    time.timeZone = "America/Denver";
    services.gnome.gnome-keyring.enable = true;
    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    programs.fish.enable = true;

    nixpkgs.config.permittedInsecurePackages = [
      "libsoup-2.74.3"
    ];

    nixpkgs.config.allowUnfree = true;

    nix = {
      settings.trusted-users = [ "root" "nicole" "brad" ];
      extraOptions = ''
        experimental-features = nix-command flakes
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';
    };
  };
}
