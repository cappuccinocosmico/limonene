{inputs, ...}: {
  flake.nixosConfigurations.junkmage = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.self.modules.nixos.display-greetd
      inputs.hardware.nixosModules.framework-12th-gen-intel
      ../../hardware/junkmage.nix
      {
        limonene.machineType = "desktop";
        limonene.autologinUser = "nicole";
        limonene.defaultSession = "sway";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        # Prevent overheating on framework
        services.throttled.enable = true;
        networking.hostName = "junkmage";

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
