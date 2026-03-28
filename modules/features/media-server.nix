{ inputs, lib, ... }: {
  flake.modules.nixos.mediaServer = { pkgs, ... }: {
    virtualisation.docker.enable = lib.mkForce false;

    services.jellyfin = {
      enable = true;
      openFirewall = true;
      user = "jellyfin";
    };

    users.groups.jellyfin = {};
    users.users.jellyfin = {
      isSystemUser = true;
      description = "Jellyfin System User";
      shell = pkgs.bashInteractive;
      extraGroups = [ "render" "video" ];
    };

    services.gvfs.enable = true;
    services.udisks2.enable = true;

    services.nfs.server.enable = true;

    virtualisation.containers = {
      enable = true;
      registries.search = [ "docker.io" ];
      policy = {
        default = [ { type = "insecureAcceptAnything"; } ];
        transports = {
          docker-daemon = {
            "" = [ { type = "insecureAcceptAnything"; } ];
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
