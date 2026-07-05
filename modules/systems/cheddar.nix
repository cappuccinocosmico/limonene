{inputs, ...}: {
  flake.darwinConfigurations.cheddar = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      inputs.self.modules.darwin.darwinWm
      inputs.home-manager.darwinModules.home-manager
      inputs.self.modules.darwin.users-brad
      inputs.self.modules.darwin.homebrew
      {
        nixpkgs.overlays = [
          inputs.rust-overlay.overlays.default
        ];

        nix.enable = false;

        environment.systemPackages = [
          inputs.nixpkgs.legacyPackages.aarch64-darwin.pkg-config
          inputs.nixpkgs.legacyPackages.aarch64-darwin.openssl
        ];

        environment.shellAliases = {
          nrs = "sudo darwin-rebuild switch --flake /Users/nicole/limonene#cheddar";
        };

        nixpkgs.config.allowUnfree = true;

        users.users.nicole = {
          name = "nicole";
          home = "/Users/nicole";
        };

        system.primaryUser = "nicole";

        home-manager.users.nicole = {pkgs, ...}: {
          imports = [
            inputs.self.modules.homeManager.userCommon
            inputs.self.modules.homeManager.opencode
          ];

          home.sessionVariables = {
            NIXPKGS_ALLOW_UNFREE = "1";
            PNPM_HOME = "$HOME/.binaries/pnpm";
            SHELL = "${pkgs.fish}/bin/fish";
          };

          home.sessionPath = [
            "$HOME/.binaries/pnpm"
          ];

          programs.fish = {
            shellInit = ''
              fish_add_path /run/current-system/sw/bin
              fish_add_path /nix/var/nix/profiles/default/bin
            '';
          };

          programs.git = {
            enable = true;
            lfs.enable = false;
            settings = {
              user = {
                name = "Nicole Venner";
                email = "nvenner@protonmail.ch";
              };
              init.defaultBranch = "main";
              pull.rebase = true;
            };
          };

          home = {
            username = "nicole";
            homeDirectory = "/Users/nicole";
            stateVersion = "25.05";
          };
        };

        system.stateVersion = 5;
      }
    ];
    specialArgs = {inherit inputs;};
  };
}
