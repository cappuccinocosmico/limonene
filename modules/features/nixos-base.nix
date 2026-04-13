{inputs, ...}: {
  imports = [inputs.flake-parts.flakeModules.modules];

  systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

  flake.modules.nixos.base = {
    inputs,
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      rustDev
    ];
    environment.etc."nixos/limonene".source = ../..;

    nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
      inputs.nix-vscode-extensions.overlays.default
      inputs.nur.overlays.default
    ];

    environment.systemPackages = [
      (import ../../helpers/regular-linux-shell.nix {inherit pkgs;})
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

    boot.binfmt.emulatedSystems = ["aarch64-linux"];
    boot.binfmt.registrations."aarch64-linux".fixBinary = true;

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

    # virtualisation.docker.enable = true;
    virtualisation.waydroid.enable = true;
    services.tailscale.enable = true;

    networking.networkmanager.enable = true;
    hardware.enableAllFirmware = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

    networking.firewall = {
      enable = false;
      allowedTCPPorts = [80 443 8080 8443];
      extraCommands = ''
        iptables -A INPUT -p tcp --dport 22 -s 192.168.0.0/16 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/8 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -s 172.16.0.0/12 -j ACCEPT
        iptables -A INPUT -p tcp --dport 22 -j DROP
      '';
    };

    time.timeZone = "America/Denver";
    services.gnome.gnome-keyring.enable = true;

    # Autodiscover printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };

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
      settings.trusted-users = ["root"];
      extraOptions = ''
        experimental-features = nix-command flakes
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';
    };
  };
}
