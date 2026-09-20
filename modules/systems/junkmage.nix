{inputs, ...}: {
  flake.nixosConfigurations.junkmage = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.hardware.nixosModules.framework-12th-gen-intel
      ../../hardware/junkmage.nix
      {
        limonene.autologinUser = "nicole";
        limonene.defaultSession = "sway";

        home-manager.users.nicole.imports = [inputs.self.modules.homeManager.nicole-desktop];

        # Prevent overheating on framework
        services.throttled.enable = true;
        networking.hostName = "junkmage";
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
