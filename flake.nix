{
  description = "Smells Strongly of Oranges";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:NixOS/nixos-hardware";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  outputs =
    { 
      self, 
      nixpkgs, 
      home-manager,  
      hardware, 
      rust-overlay,
      nix-vscode-extensions, 
      determinate,
      ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

    in
    {
      nixosConfigurations = {
        incarnadine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ 
                rust-overlay.overlays.default
                nix-vscode-extensions.overlays.default
              ];
              environment.systemPackages = [
                (import ./modules/regular-linux-shell.nix { inherit pkgs; })
                # pkgs.rust-bin.stable.latest.default
                # (pkgs.rust-bin.stable.latest.default.override {
                #   extensions = [ "rust-analyzer" ];
                # })
                # pkgs.rustup
                pkgs.libclang
                pkgs.pkg-config
                pkgs.openssl
              ];
            })
            ./system/incarnadine-configuration.nix  # Import your system configuration file
            # ./modules/otel_setup.nix
            hardware.nixosModules.framework-amd-ai-300-series
            determinate.nixosModules.default
            # Enable home-manager as a NixOS module
            home-manager.nixosModules.home-manager

            # Home-manager config for user 'nicole'
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.nicole = {
                imports = [
                  # inputs.nixvim.homeModules.nixvim
		  
                  ./home/nicole.nix
                ];
              };
            }

          ];

          # Pass the flake as an argument for the system
          specialArgs = { inherit inputs; };
        };
        vermissian = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ 
                rust-overlay.overlays.default
                nix-vscode-extensions.overlays.default
              ];
              environment.systemPackages = [
                (import ./modules/regular-linux-shell.nix { inherit pkgs; })
                # pkgs.rust-bin.stable.latest.default
                # (pkgs.rust-bin.stable.latest.default.override {
                #   extensions = [ "rust-analyzer" ];
                # })
                # pkgs.rustup
                  pkgs.libclang
                  pkgs.pkg-config
                  pkgs.openssl
                ];
              })
              ./system/vermissian-configuration.nix  # Import your system configuration file
              # ./modules/otel_setup.nix
              hardware.nixosModules.framework-amd-ai-300-series
              # Enable home-manager as a NixOS module
              home-manager.nixosModules.home-manager
              determinate.nixosModules.default
  
  
              # Home-manager config for user 'nicole'
              {
                home-manager.useUserPackages = true;
                home-manager.useGlobalPkgs = true;
                home-manager.users.nicole = {
                  imports = [
                    # inputs.nixvim.homeModules.nixvim
        
                    ./home/nicole.nix
                  ];
                };
              }
  
            ];
  
            # Pass the flake as an argument for the system
            specialArgs = { inherit inputs; };
          };
        };
    };
}
