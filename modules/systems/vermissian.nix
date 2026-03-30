{inputs, ...}: {
  flake.nixosConfigurations.vermissian = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.self.modules.nixos.sway
      inputs.self.modules.nixos.display-ly
      inputs.hardware.nixosModules.framework-amd-ai-300-series
      ../../hardware/vermissian.nix
      {
        limonene.machineType = "desktop";
        limonene.autologinUser = "nicole";
        limonene.defaultSession = "sway";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        networking.hostName = "vermissian";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.initrd.luks.devices."luks-ff4e0550-7152-4404-8b86-f76ad713b49e".device = "/dev/disk/by-uuid/ff4e0550-7152-4404-8b86-f76ad713b49e";

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

        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        system.stateVersion = "25.05";
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
