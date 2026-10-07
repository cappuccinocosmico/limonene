{inputs, ...}: {
  # amon-sul — first cococoir ("fortress") box on real hardware.
  #
  # Split per ADR-037: THIS machine flake owns HARDWARE ONLY (boot, disks,
  # network, users, the btrfs mount). The fortress APP config (services,
  # exposure, secrets) lives in the stateful magic folder at
  # /etc/fortress/config and is applied at run time by the applier
  # trampoline. See archive/amon-sul/ for what the previous all-in-one
  # config carried.
  #
  # It imports ONLY `nixosModules.applier` — never `nixosModules.default`,
  # which would drag the fortress service closure into the nixos-rebuild
  # closure and re-couple the two lifecycles (ADR-035). The fortress
  # surface of this machine is the single line `fortress.applier.enable`.
  #
  # `pkgs`/`lib` still come from cococoir's nixpkgs (the box's current OS
  # generation) so this cutover changes the fortress surface and nothing
  # else. Moving the machine onto limonene's own nixpkgs is a separate,
  # independent step.
  flake.nixosConfigurations.amon-sul = inputs.cococoir.inputs.nixpkgs.lib.nixosSystem {
    pkgs = inputs.cococoir.lib.mkPkgs "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.cococoir.nixosModules.applier
      ../../hardware/amon-sul.nix
      ({
        config,
        lib,
        pkgs,
        ...
      }: {
        networking.hostName = "amon-sul";
        system.stateVersion = "24.11";
        time.timeZone = "America/Denver";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # ── Network: static, because this NIC's DHCP never leases and
        # dhcpcd then drops the explicit nameservers (resolv.conf comes
        # up with no `nameserver` line → DNS dead). ──────────────────
        networking.useDHCP = false;
        networking.interfaces.enp11s0 = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "192.168.0.7";
              prefixLength = 24;
            }
          ];
        };
        networking.defaultGateway = "192.168.0.1";
        networking.nameservers = ["8.8.8.8" "1.1.1.1"];
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [22 80 443 53];
          allowedUDPPorts = [53];
        };

        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
        };

        # Keep the box on the tailnet — it is how it is administered
        # from outside the LAN, independent of the edge tunnel.
        services.tailscale.enable = true;
        # ...but stop it owning /etc/resolv.conf. tailscale's MagicDNS
        # (100.100.100.100) does not resolve public names on this tailnet,
        # so the box has had no working DNS — `github.com` and
        # `cache.nixos.org` fail to resolve, which breaks every Nix fetch
        # (found 2026-10-06; it is why the applier's boot-time build could
        # not work). `extraSetFlags` runs `tailscale set` at boot and does
        # not need an auth key; without DNS management the static
        # `networking.nameservers` above take effect.
        services.tailscale.extraSetFlags = ["--accept-dns=false"];

        nix.settings = {
          experimental-features = ["nix-command" "flakes"];
          trusted-users = ["root"];
        };

        # No `jellyfin` extra group: jellyfin runs as root under the
        # applier (ADR-036), so the group no longer exists and naming it
        # here would be a dangling reference.

        users.users.nicole = {
          isNormalUser = true;
          description = "Nicole";
          extraGroups = ["wheel"];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBfMZjr6H4oK3qSBTxjZrMZptWXdzYC6QV4bdS892Ls nicole@vermissian"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtpDAeIfLOlZE5y/SaHQ8h60nqbPSWdStRsvux6ECbk nicole@idol"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOoMeFDsyCKC9zi/8CdC5AcL467TYRQllrzrWOCutYHY nicole@vermissian"
          ];
        };

        users.users.root = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBfMZjr6H4oK3qSBTxjZrMZptWXdzYC6QV4bdS892Ls nicole@vermissian"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtpDAeIfLOlZE5y/SaHQ8h60nqbPSWdStRsvux6ECbk nicole@idol"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOoMeFDsyCKC9zi/8CdC5AcL467TYRQllrzrWOCutYHY nicole@vermissian"
          ];
        };
        users.users.brad = {
          isNormalUser = true;
          description = "Brad";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaOgK4fO5gTB79Infge2b+31VzXnC23lqV7m5NA+xuz bvenner@proton.me"
          ];
        };
        users.users.matthewkrumlauf.isNormalUser = true;

        programs.fish.enable = true;
        environment.systemPackages = with pkgs; [git fish];

        # ── Storage (hardware layer) ────────────────────────────────
        # The `tank` pool was formatted by the old fortress storage
        # module and is already populated (7.6T). The machine owns the
        # mount now; the app config points `storage.dataRoot` at
        # /media (plain-dirs). ADR-037: btrfs is host-owned.
        boot.supportedFilesystems = ["btrfs"];
        fileSystems."/media" = {
          device = "/dev/disk/by-uuid/5424a16e-700b-4620-b7f9-713a1619eb88";
          fsType = "btrfs";
          options = ["defaults" "compress=zstd" "subvolid=5"];
        };
        services.btrfs.autoScrub = {
          enable = true;
          fileSystems = ["/media"];
        };

        # The applier installs fortress units into /run/systemd/system,
        # which is tmpfs — so the trampoline re-applies on every boot.
        # The vhost loopback aliases stay on the machine: the applier
        # cannot write /etc/hosts.
        networking.hosts."127.0.0.1" = [
          "jellyfin.fractal.interdim.net"
          "auth.fractal.interdim.net"
          "cryptpad.fractal.interdim.net"
          "git.fractal.interdim.net"
        ];

        # ── The one fortress line (ADR-037) ─────────────────────────
        fortress.applier.enable = true;
      })
    ];
  };
}
