{
  description = "Smells Strongly of Oranges";
 
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = github:nixos/nixos-hardware;
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self,nixpkgs, home-manager,hardware,... }@inputs:
  let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in
  rec {

    nixosConfigurations = {
      # FIXME replace with your hostname
      apiarist = nixpkgs.lib.nixosSystem {
        system="x86_64-linux";
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [ ./system.nix ./hardware/apiarist.nix
          home-manager.nixosModules.home-manager{
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages= true;
          }
        ];
      };
    };

    nixConfig = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://helix.cachix.org"
        "https://fufexan.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://hyprland.cachix.org"
        "https://cache.privatevoid.net"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
      ];
  };
  };
}
