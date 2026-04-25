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
      openFirewall = true;
      user = "jellyfin";
    };
    services.cryptpad = {
      enable = true;
      settings = {
        httpPort = 9000;
        httpAddress = "0.0.0.0";
        httpUnsafeOrigin = "http://localhost:${toString config.services.cryptpad.settings.httpPort}";
        httpSafeOrigin = "http://localhost:${toString config.services.cryptpad.settings.httpPort}";
      };
    };
    vpnNamespaces.wg = {
      enable = true;
      wireguardConfigFile = "/etc/nixos/secrets/privado.den-017.conf";
      accessibleFrom = ["127.0.0.1" "192.168.0.0/16"];
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
      openRPCPort = true;
      openPeerPorts = true;
      user = "jellyfin";
      group = "jellyfin";
      settings = {
        rpc-bind-address = "192.168.15.1";
        rpc-whitelist = "192.168.15.5,127.0.0.1,192.168.0.*,192.168.68.*";
        peer-port = 51413;
        download-dir = "/media/entertain";
      };
    };

    networking.firewall.allowedTCPPorts = [111 2049 4000 4001 4002 9091 20048 51413 9000];
    networking.firewall.allowedUDPPorts = [111 2049 4000 4001 4002 9091 20048 51413 9000];
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
