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
    nixpkgs = {
      overlays = [
        inputs.rust-overlay.overlays.default
        inputs.nix-vscode-extensions.overlays.default
        inputs.nur.overlays.default
        (_: prev: {
          openldap = prev.openldap.overrideAttrs {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          };
        })
      ];
      config = {
        allowUnfree = true;
      };
    };
    imports = with inputs.self.modules.nixos; [
      rustDev
      nixld
    ];
    environment.etc."nixos/limonene".source = ../..;

    environment.systemPackages = with pkgs; [
      (import ../../helpers/regular-linux-shell.nix {inherit pkgs;})
      libclang
      pkg-config
      openssl
      brightnessctl
      fwupd
      stress
      phoronix-test-suite
      lutris
      winetricks
      wineWow64Packages.stable
      yggdrasil
      python314
      postgresql_17
      nix-ld
      heroic
      feather
      devenv
      gnome-disk-utility
      git
      gcc
      openssl_3
      msr-tools
      parted
      emissary
      nix-update
      nixpkgs-review
    ];
    services.i2pd = {
      enable = true;
      bandwidth = 4096; # increase bandwidth limit to 4Mb/s instead of 32kb/s
      proto.httpProxy.enable = true;
      proto.http.enable = true;
      proto.socksProxy.enable = true;
    };

    boot.binfmt.emulatedSystems = ["aarch64-linux"];
    boot.binfmt.registrations."aarch64-linux".fixBinary = true;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    services.atd.enable = true;
    services.fwupd.enable = true;

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="serio", KERNEL=="serio0", ATTR{power/wakeup}="disabled"
    '';

    # virtualisation.docker.enable = true;
    # virtualisation.waydroid.enable = true;
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

    nixpkgs.config.

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
