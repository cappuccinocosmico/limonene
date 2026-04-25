{...}: {
  flake.modules.nixos.mediaServer = {
    pkgs,
    config,
    inputs,
    lib,
    ...
  }: {
    virtualisation.docker.enable = lib.mkForce false;

    services.jellyfin = {
      enable = true;
      openFirewall = false;
      user = "jellyfin";
    };
    services.cryptpad = {
      enable = true;
      settings = {
        httpPort = 9000;
        httpAddress = "127.0.0.1";
        httpUnsafeOrigin = "http://localhost:${toString config.services.cryptpad.settings.httpPort}";
        httpSafeOrigin = "http://localhost:${toString config.services.cryptpad.settings.httpPort}";
      };
    };

    vpnNamespaces.wg = {
      enable = true;
      wireguardConfigFile = "/etc/nixos/secrets/privado.den-017.conf";
      accessibleFrom = ["127.0.0.1"];
      portMappings = [
        {
          from = 9091;
          to = 9091;
        }
      ];
      openVPNPorts = [
        {
          port = 51413;
          protocol = "both";
        }
      ];
    };

    systemd.services.transmission.vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };

    services.transmission = {
      enable = true;
      package = inputs.nixpkgs.legacyPackages.x86_64-linux.transmission_4;
      openRPCPort = false;
      openPeerPorts = true;
      user = "jellyfin";
      group = "jellyfin";
      settings = {
        rpc-bind-address = "192.168.15.1";
        rpc-whitelist = "127.0.0.1";
        peer-port = 51413;
        download-dir = "/media/entertain";
      };
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        interface = "enp11s0";
        bind-interfaces = true;
        server = ["8.8.8.8" "1.1.1.1"];
        address = "/amon-sul.internal/192.168.0.7";
      };
    };

    services.caddy = {
      enable = true;
      extraConfig = ''
        {
          auto_https off
        }

        jellyfin.amon-sul.internal {
          reverse_proxy localhost:8096
        }

        cryptpad.amon-sul.internal {
          reverse_proxy localhost:9000
        }

        transmission.amon-sul.internal {
          reverse_proxy localhost:9091
        }
      '';
    };

    networking.firewall.allowedTCPPorts = [53 80 111 2049 4000 4001 4002 443 20048 51413];
    networking.firewall.allowedUDPPorts = [53 80 111 2049 4000 4001 4002 443 20048 51413];
    users.groups.jellyfin = {};
    users.users.jellyfin = {
      isSystemUser = true;
      description = "Jellyfin System User";
      shell = pkgs.bashInteractive;
      extraGroups = ["render" "video"];
    };

    services.gvfs.enable = true;
    services.udisks2.enable = true;

    services.nfs.server.enable = true;

    virtualisation.containers = {
      enable = true;
      registries.search = ["docker.io"];
      policy = {
        default = [{type = "insecureAcceptAnything";}];
        transports = {
          docker-daemon = {
            "" = [{type = "insecureAcceptAnything";}];
          };
        };
      };
    };

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
      wireguard-tools
      dive
      podman-tui
      docker-compose
      podman-compose
    ];
  };
}
