{
  description = "Smells Strongly of Oranges";
 
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hardware.url = github:NixOS/nixos-hardware;

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # this line assume that you also have nixpkgs as an input
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager,  hardware, rust-overlay,... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."nicole" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home/nicole.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit inputs; };
      };
      # NixOS system configuration
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [
                (pkgs.rust-bin.stable.latest.default.override {
                  extensions = [ "rust-analyzer" ];
                })
              ];
            })
            ./configuration.nix  # Import your system configuration file
            hardware.nixosModules.framework-amd-ai-300-series
            # Enable home-manager as a NixOS module
            home-manager.nixosModules.home-manager

            # Home-manager config for user 'nicole'
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.nicole = import ./home/nicole.nix;
            }

          ];

          # Pass the flake as an argument for the system
          specialArgs = { inherit inputs; };
        };
      };
    };
}
