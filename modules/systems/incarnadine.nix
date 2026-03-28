{ inputs, lib, ... }: {
  flake.nixosConfigurations.incarnadine = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.users.nicole
      inputs.hardware.nixosModules.framework-amd-ai-300-series
      ../../hardware/incarnadine.nix
      {
        limonene.machineType = "desktop";

        networking.hostName = "incarnadine";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.initrd.luks.devices."luks-e4c4f4e3-e6c7-43f2-8a41-5bc7add2a577".device = "/dev/disk/by-uuid/e4c4f4e3-e6c7-43f2-8a41-5bc7add2a577";

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

        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = true;
          openFirewall = true;
        };

        environment.systemPackages = [ inputs.nixpkgs.legacyPackages.x86_64-linux.wlr-randr ];

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        users.users.nicole.extraGroups = [ "video" "render" ];

        home-manager.users.nicole = {
          services.swayidle.enable = lib.mkForce false;
        };

        system.stateVersion = "25.05";
      }
    ];
    specialArgs = { inherit inputs; };
  };
}
