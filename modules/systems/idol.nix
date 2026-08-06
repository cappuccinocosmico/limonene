{inputs, ...}: {
  flake.nixosConfigurations.idol = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.self.modules.nixos.gaming
      inputs.self.modules.nixos.display-greetd
      inputs.hardware.nixosModules.framework-16-amd-ai-300-series
      # inputs.hardware.nixosModules.common-cpu-amd
      # inputs.hardware.nixosModules.common-cpu-amd-pstate
      # inputs.hardware.nixosModules.common-gpu-amd
      # inputs.hardware.nixosModules.common-pc-ssd
      ../../hardware/idol.nix
      {
        limonene.machineType = "desktop";
        limonene.autologinUser = "nicole";
        limonene.defaultSession = "sway";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        networking.hostName = "idol";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.initrd.luks.devices."luks-099e44df-0372-4808-bf9a-74f2dba56f71".device = "/dev/disk/by-uuid/099e44df-0372-4808-bf9a-74f2dba56f71";

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
