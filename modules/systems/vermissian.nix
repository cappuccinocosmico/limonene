{inputs, ...}: {
  flake.nixosConfigurations.vermissian = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.self.modules.nixos.base
      inputs.self.modules.nixos.common
      inputs.self.modules.nixos.general
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
      }
      inputs.self.modules.nixos.users-nicole
      inputs.self.modules.nixos.sway
      inputs.self.modules.nixos.gaming
      inputs.self.modules.nixos.display-greetd
      inputs.self.modules.nixos.ollama
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-cpu-amd-pstate
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      ../../hardware/vermissian.nix
      {
        limonene.machineBehaviors.disableSleep.enable = true;
        limonene.machineBehaviors.turnOffDisplay.enable = true;
        limonene.autologinUser = "nicole";
        limonene.defaultSession = "sway";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        networking.hostName = "vermissian";

        boot.initrd.luks.devices."luks-1b5555a7-d2e4-4cf2-9654-f19eb0dfc349".device = "/dev/disk/by-uuid/1b5555a7-d2e4-4cf2-9654-f19eb0dfc349";
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
