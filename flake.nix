{
  description = "Smells Strongly of Oranges";
 
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = github:NixOS/nixos-hardware;

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
    
    # nixos-cli
    nixos-cli.url = "github:nix-community/nixos-cli";

    # neovim configuration
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs =
    { self, nixpkgs, home-manager,  hardware, rust-overlay, nixos-cli, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      nvim_config = import ./nvim;
      nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = nvim_config;
      };
      nvimWithMeta = nvim.overrideAttrs (oldAttrs: {
        meta = (oldAttrs.meta or {}) // {
          description = "Neovim configured with nixvim";
          longDescription = "Custom Neovim configuration built with nixvim, originally from: https://github.com/XhuyZ/nixvim";
          license = pkgs.lib.licenses.mit;
          maintainers = [ ];
          platforms = pkgs.lib.platforms.unix;
        };
      });
    in
    {
      homeConfigurations."nicole" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home/nicole.nix
          {
            programs.neovim = {
              enable = true;
              package=nvimWithMeta;
              viAlias = true;
              vimAlias = true;
            };
          }
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit inputs; };
      };
      # NixOS system configuration
      nixosConfigurations = {
        incarnadine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [
                (import ./regular-linux-shell.nix { inherit pkgs; })
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
            ./configuration.nix  # Import your system configuration file
            ./otel_setup.nix
            hardware.nixosModules.framework-amd-ai-300-series
            # Enable home-manager as a NixOS module
            home-manager.nixosModules.home-manager
            
            # nixos-cli module
            nixos-cli.nixosModules.nixos-cli

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
