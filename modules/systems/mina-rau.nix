{ inputs, ... }: {
  flake.nixosConfigurations.mina-rau = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.common
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
      }
      inputs.self.modules.nixos.users-brad
      inputs.self.modules.nixos.plasma
      inputs.self.modules.nixos.display-ly
      inputs.hardware.nixosModules.framework-amd-ai-300-series
      ../../hardware/mina-rau.nix
      inputs.self.modules.nixos.bradBase
      inputs.self.modules.nixos.gaming
      {
        limonene.machineType = "desktop";

        home-manager.users.brad.imports = [ inputs.self.modules.homeManager.brad-desktop ];

        networking.hostName = "mina-rau";

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

        services.xserver.xkb = { layout = "us"; variant = ""; };

        system.stateVersion = "25.05";
      }
    ];
    specialArgs = { inherit inputs; };
  };
}
