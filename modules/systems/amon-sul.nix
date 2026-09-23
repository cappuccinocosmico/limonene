{
  inputs,
  ...
}: {
  # amon-sul — the first cococoir ("fortress") box on real hardware.
  #
  # Deliberately barebones: this machine imports nothing else from
  # limonene (no base/common/general/desktop modules). It pulls the
  # product in as a flake input and writes only the handful of things
  # that are genuinely per-machine: disks, network, users, the
  # fortress service toggles, and the tunnel to the edge.
  #
  # Everything a customer would set lives under `fortress.*` (see
  # nix/nixos-modules/fortress.nix upstream). Secrets are generated on
  # first boot by the modules (jellarr API key, OIDC client secrets),
  # so no sops wiring is needed here.
  flake.nixosConfigurations.amon-sul =
    # `lib` must come from the SAME nixpkgs as `pkgs` below; mixing
    # limonene's nixpkgs lib (26.05) with the product's unstable pkgs
    # makes the module system evaluate `pkgs.stdenv.hostPlatform` with
    # the wrong schema (e.g. `linux-kernel` missing).
    inputs.cococoir.inputs.nixpkgs.lib.nixosSystem {
      # The product's pkgs factory, not limonene's nixpkgs: the modules
      # callPackage a crane-built Rust client and build jellarr, both of
      # which need this flake's build wiring (see flake.lib.mkPkgs
      # upstream).
      pkgs = inputs.cococoir.lib.mkPkgs "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        inputs.cococoir.nixosModules.default
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

        nix.settings = {
          experimental-features = ["nix-command" "flakes"];
          trusted-users = ["root"];
        };

        users.users.nicole = {
          isNormalUser = true;
          description = "Nicole";
          extraGroups = ["wheel" "jellyfin"];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBfMZjr6H4oK3qSBTxjZrMZptWXdzYC6QV4bdS892Ls nicole@vermissian"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtpDAeIfLOlZE5y/SaHQ8h60nqbPSWdStRsvux6ECbk nicole@idol"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOoMeFDsyCKC9zi/8CdC5AcL467TYRQllrzrWOCutYHY nicole@vermissian"
          ];
        };
        users.users.brad = {
          isNormalUser = true;
          description = "Brad";
          extraGroups = ["jellyfin"];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaOgK4fO5gTB79Infge2b+31VzXnC23lqV7m5NA+xuz bvenner@proton.me"
          ];
        };
        users.users.matthewkrumlauf.isNormalUser = true;

        programs.fish.enable = true;
        environment.systemPackages = with pkgs; [git fish];

        # ── The product ─────────────────────────────────────────────
        fortress = {
          baseDomain = "fractal.interdim.net";
          tls.mode = "acme";
          network.lanAddress = "192.168.0.7";

          services = {
            jellyfin = {
              enable = true;
              public = true;
              mediaRoot = "/media/entertain";
            };
            dex.public = true;
            cryptpad.public = true;
            forgejo.public = true;
            media.enable = true;
            # The *arr / download UIs have no SSO behind them, so they
            # stay off the public vhosts (Caddy answers 403). The
            # automation itself talks to them over loopback.
            radarr.public = false;
            sonarr.public = false;
            qbittorrent.public = false;
            seerr.public = false;
          };

          storage.btrfs.pool = {
            name = "tank";
            devices = ["/dev/sda1"];
            layout = "stripe";
            mountpoint = "/media";
          };
        };

        # The service contract's vhosts require this explicitly (the
        # factory asserts it rather than enabling it).
        services.caddy.enable = true;

        # The product's default Jellyfin libraries scan
        # `<mediaRoot>/<type>/library` (the *arr hardlink-import
        # layout). amon-sul's existing media predates that layout and
        # sits directly in `/media/entertain/<type>`, so point the
        # libraries at what is actually on disk. `virtualFolders` is
        # mkDefault upstream; this is the intended override.
        services.jellarr.config.library.virtualFolders = [
          {
            name = "Movies";
            collectionType = "movies";
            libraryOptions.pathInfos = [{path = "/media/entertain/movies";}];
          }
          {
            name = "TV Shows";
            collectionType = "tvshows";
            libraryOptions.pathInfos = [{path = "/media/entertain/shows";}];
          }
          {
            name = "Music";
            collectionType = "music";
            libraryOptions.pathInfos = [{path = "/media/entertain/music";}];
          }
        ];

        # OIDC accounts. Hashes replaced at deploy time, not committed
        # long-term.
        services.dex.settings.staticPasswords = [
          {
            email = "nicole@fractal.interdim.net";
            hash = "$2b$10$ab2woi0QuI5sczAk3Wg1EOtdh9DgGQjUF9YyKhKIBu9UOmn1G0Dmu";
            username = "nicole";
            userID = "00000000-0000-0000-0000-000000000001";
            groups = ["admins"];
          }
          {
            email = "brad@fractal.interdim.net";
            hash = "$2b$10$lBlef1v6je65.nf8h5kud..ChUot1RV1EMAVVdlBHQ.bhSqID5A0y";
            username = "brad";
            userID = "00000000-0000-0000-0000-000000000002";
            groups = ["users"];
          }
        ];

        # ── Tunnel client half (ADR-025): the client owns wg0 and
        # dials out to the edge; the forwarder carries the edge's
        # :80/:443 onto local Caddy, which terminates real ACME certs
        # obtained through the tunnel. ─────────────────────────────
        services.fortress-client.enable = true;

        # One-time migration: the legacy cococoir client persisted its
        # WireGuard identity under /var/lib/cococoir; the v2 client
        # reads it from /var/lib/fortress. Without this copy the client
        # generates a brand-new keypair the edge has never registered,
        # and the tunnel (and therefore ACME) never comes up.
        systemd.services.fortress-legacy-wg-key = {
          wantedBy = ["fortress-client.service"];
          before = ["fortress-client.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            if [ ! -s /var/lib/fortress/wg-private.key ] && [ -s /var/lib/cococoir/wg-private.key ]; then
              ${pkgs.coreutils}/bin/install -D -m 0600 -o root -g root \
                /var/lib/cococoir/wg-private.key /var/lib/fortress/wg-private.key
            fi
          '';
        };

        environment.etc."fortress-client.json".text = builtins.toJSON {
          tunnel = {
            ip = "10.10.0.3";
            prefix = 24;
            edge_pubkey = "lX+5lGEF1qDJEag13Kymyxy/SJH63LPxKTvMg50WE2E=";
            edge_endpoint = "62.238.111.21:51820";
            edge_allowed_ips = "10.10.0.0/24";
          };
          forwards = [
            {
              listen_addr = "10.10.0.3:80";
              proto = "tcp";
              dest_addr = "127.0.0.1:80";
            }
            {
              listen_addr = "10.10.0.3:443";
              proto = "tcp";
              dest_addr = "127.0.0.1:443";
            }
          ];
        };

        networking.hosts."127.0.0.1" = [
          "jellyfin.fractal.interdim.net"
          "auth.fractal.interdim.net"
          "cryptpad.fractal.interdim.net"
          "git.fractal.interdim.net"
        ];
      })
    ];
  };
}
