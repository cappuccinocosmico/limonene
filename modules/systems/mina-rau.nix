{ inputs, ... }: {
  flake.nixosConfigurations.mina-rau = inputs.nixpkgs.lib.nixosSystem {
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
      inputs.self.modules.nixos.users-brad
      inputs.self.modules.nixos.plasma
      inputs.self.modules.nixos.display-greetd
      inputs.hardware.nixosModules.framework-amd-ai-300-series
      ../../hardware/mina-rau.nix
      inputs.self.modules.nixos.bradBase
      inputs.self.modules.nixos.gaming
      {
        home-manager.users.brad.imports = [ inputs.self.modules.homeManager.brad-desktop ];

        networking.hostName = "mina-rau";
      }
    ];
    specialArgs = { inherit inputs; };
  };
}
