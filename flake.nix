{
  description = "Smells Strongly of Oranges";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

      # Per-system packages
      perSystem = {
        system,
        pkgs,
        self',
        ...
      }: {
        packages.nvim =
          (inputs.nvf.lib.neovimConfiguration {
            modules = [./home/common/nvim.nix];
            inherit pkgs;
          }).neovim;

        apps.default = {
          type = "app";
          program = "${self'.packages.nvim}/bin/nvim";
        };
      };

      # Shared base configuration for all NixOS systems
      flake.lib.baseNixOSModules = [
        ({pkgs, ...}: {
          nixpkgs.overlays = [
            inputs.rust-overlay.overlays.default
            inputs.nix-vscode-extensions.overlays.default
          ];
          environment.systemPackages = [
            (import ./modules/regular-linux-shell.nix {inherit pkgs;})
            pkgs.libclang
            pkgs.pkg-config
            pkgs.openssl
          ];
        })
        inputs.hardware.nixosModules.framework-amd-ai-300-series
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
          home-manager.users.nicole = {
            imports = [
              ./nicole/nicole.nix
              inputs.nvf.homeManagerModules.default
            ];
          };
        }
      ];

      flake.nixosConfigurations = {
        incarnadine = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [
              ./system/incarnadine-configuration.nix
            ]
            ++ inputs.self.lib.baseNixOSModules;
          specialArgs = {inherit inputs;};
        };

        vermissian = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [
              ./system/vermissian-configuration.nix
              # inputs.hyphae.nixosModules.default
            ]
            ++ inputs.self.lib.baseNixOSModules;
          specialArgs = {inherit inputs;};
        };

        # Brad's computer - KDE Plasma desktop environment
        mina-rau = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./system/mina-rau-configuration.nix
            # Include common overlays and packages
            ({pkgs, ...}: {
              nixpkgs.overlays = [
                inputs.rust-overlay.overlays.default
                inputs.nix-vscode-extensions.overlays.default
              ];
              environment.systemPackages = [
                (import ./modules/regular-linux-shell.nix {inherit pkgs;})
                pkgs.libclang
                pkgs.pkg-config
                pkgs.openssl
              ];
            })
            inputs.hardware.nixosModules.framework-amd-ai-300-series
            # Brad's home-manager configuration
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.brad = {
                imports = [
                  ./others/brad/brad.nix
                  inputs.nvf.homeManagerModules.default
                ];
              };
            }
          ];
          specialArgs = {inherit inputs;};
        };
      };

      # macOS/Darwin configurations
      flake.darwinConfigurations = {
        # Replace "nicole-mac" with your Mac's hostname
        # Run: scutil --get LocalHostName
        "cheddar" = inputs.nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # Use "x86_64-darwin" for Intel Macs
          modules = [
            ./system/darwin-wm.nix
            ({pkgs, ...}: {
              nixpkgs.overlays = [
                inputs.rust-overlay.overlays.default
                inputs.spacebar.overlay.aarch64-darwin
              ];

              # Basic nix-darwin configuration
              nix.enable = false;
              # nix.settings.experimental-features = [ "nix-command" "flakes" ];

              # System packages available to all users
              environment.systemPackages = [
                pkgs.pkg-config
                pkgs.openssl
              ];

              # Shell aliases for darwin
              environment.shellAliases = {
                nrs = "sudo darwin-rebuild switch --flake /Users/nicole/limonene#cheddar";
              };

              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;

              # Set your primary user
              users.users.nicole = {
                name = "nicole";
                home = "/Users/nicole";
              };

              # Primary user for services that require user-level activation
              system.primaryUser = "nicole";

              nix.settings = {
                extra-substituters = [
                  "https://devenv.cachix.org"
                ];
                extra-trusted-public-keys = [
                  "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
                ];
              };

              # Used for backwards compatibility
              system.stateVersion = 5;
            })
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.nicole = {
                imports = [
                  ./nicole/nicole-darwin.nix
                  inputs.nvf.homeManagerModules.default
                ];
              };
            }
          ];
          specialArgs = {inherit inputs;};
        };
      };
    };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake parts for better organization
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-darwin for macOS
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:NixOS/nixos-hardware";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # Hyphae distributed storage system
    # hyphae.url = "path:/home/nicole/Documents/hyphae";
    # hyphae.inputs.nixpkgs.follows = "nixpkgs";

    # nvf for Neovim configuration
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    # spacebar for macOS status bar
    spacebar.url = "github:cmacrae/spacebar/v1.4.0";
    spacebar.inputs.nixpkgs.follows = "nixpkgs";
  };
}
