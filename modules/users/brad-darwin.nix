{inputs, ...}: {
  flake.modules.darwin.users-brad = {
    config,
    pkgs,
    ...
  }: {
    programs.fish.enable = true;

    users.knownUsers = ["brad"];

    users.users.brad = {
      name = "brad";
      description = "Brad";
      uid = 502;
      home = "/Users/brad";
      createHome = true;
      shell = pkgs.fish;
      isHidden = false;
    };

    home-manager.users.brad = {config, ...}: {
      imports = [
        inputs.self.modules.homeManager.userCommon
        inputs.self.modules.homeManager.brad-darwin-desktop
      ];

      programs.git = {
        enable = true;
        lfs.enable = false;
        settings = {
          user.name = "bvenner";
          user.email = "bvenner@proton.me";
          github.user = "bvenner";
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      home.shellAliases = {
        nrs = "sudo darwin-rebuild switch --flake ${config.home.homeDirectory}/limonene";
        nrb = "darwin-rebuild build --verbose --flake ${config.home.homeDirectory}/limonene";
      };

      home.sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
        SHELL = "${pkgs.fish}/bin/fish";
        PNPM_HOME = "$HOME/.binaries/pnpm";
      };

      home.sessionPath = ["$HOME/.binaries/pnpm"];

      home = {
        username = "brad";
        homeDirectory = "/Users/brad";
        stateVersion = "25.05";
      };
    };
  };
}
