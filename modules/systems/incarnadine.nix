{
  inputs,
  lib,
  ...
}: {
  flake.nixosConfigurations.incarnadine = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.self.modules.nixos.display-greetd
      inputs.self.modules.nixos.ollama
      inputs.hardware.nixosModules.framework-amd-ai-300-series
      ../../hardware/incarnadine.nix
      {
        limonene.machineBehaviors.disableSleep.enable = true;

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        networking.hostName = "incarnadine";

        boot.initrd.luks.devices."luks-e4c4f4e3-e6c7-43f2-8a41-5bc7add2a577".device = "/dev/disk/by-uuid/e4c4f4e3-e6c7-43f2-8a41-5bc7add2a577";

        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = true;
          openFirewall = true;
        };

        environment.systemPackages = [inputs.nixpkgs.legacyPackages.x86_64-linux.wlr-randr];

        users.users.nicole.extraGroups = ["video" "render"];
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
