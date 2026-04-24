{ inputs, ... }: {
  flake.nixosConfigurations.amon-sul = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.common
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
      }
      inputs.self.modules.nixos.users-nicole
      inputs.self.modules.nixos.users-brad
      inputs.self.modules.nixos.mediaServer
      inputs.vpn-confinement.nixosModules.default
      ../../hardware/amon-sul.nix
      ({ pkgs, ... }: {
        limonene.machineType = "server";

        networking.hostName = "amon-sul";

        networking.interfaces.enp11s0.useDHCP = false;
        networking.interfaces.enp11s0.ipv4.addresses = [
          { address = "192.168.0.7"; prefixLength = 24; }
        ];
        networking.defaultGateway = "192.168.0.1";
        networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        users.groups.brad = {};
        users.users.brad.group = "brad";
        users.users.nicole.extraGroups = [ "jellyfin" ];
        users.users.nicole.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdPzSlJ3TCzPy7R2s2OOBJbBb+U5NY8dwMlGH9wm4Ot nicole@apiarist"
        ];
        users.users.brad.extraGroups = [ "jellyfin" ];

        fileSystems."/backup" = {
          device = "/dev/disk/by-uuid/7b72c3a2-9a4b-4f43-b787-c179ec71847e";
          fsType = "btrfs";
          options = [ "users" "nofail" "x-gvfs-show" ];
        };

        fileSystems."/media" = {
          device = "/dev/disk/by-uuid/5424a16e-700b-4620-b7f9-713a1619eb88";
          fsType = "btrfs";
          options = [ "users" "nofail" "x-gvfs-show" ];
        };

        fileSystems."/export/media" = {
          device = "/media";
          fsType = "none";
          options = [ "bind" ];
        };

        services.nfs.server.exports = ''
          /media   192.168.0.0/16(rw,nohide,insecure,no_subtree_check)
        '';

        vpnNamespaces.wg = {
          enable = true;
          wireguardConfigFile = "/etc/nixos/secrets/privado.den-017.conf";
          accessibleFrom = [ "127.0.0.1" "192.168.0.0/16" ];
          portMappings = [{ from = 9091; to = 9091; }];
          openVPNPorts = [{ port = 51413; protocol = "both"; }];
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

        networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 9091 20048 51413 ];
        networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 9091 20048 51413 ];

        services.xserver.enable = true;
        services.resolved.enable = true;

        environment.variables.EDITOR = "nvim";
        environment.systemPackages = with pkgs; [
          zellij
          tmux
          neovim
          wget
          btop
          ripgrep-all
        ];

        system.stateVersion = "24.11";
      })
    ];
    specialArgs = { inherit inputs; };
  };
}
