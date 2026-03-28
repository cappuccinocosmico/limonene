{ inputs, ... }: {
  flake.modules.homeManager.bradCommon = { config, ... }: {
    imports = [ inputs.self.modules.homeManager.userCommon ];

    programs.git = {
      enable = true;
      lfs.enable = false;
      settings = {
        user = {
          name = "bvenner";
          email = "bvenner@proton.me";
        };
        github = {
          user = "bvenner";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    home.shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/limonene";
      nrb = "nixos-rebuild build --verbose --flake ${config.home.homeDirectory}/limonene";
    };
  };
}
