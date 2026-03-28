{ inputs, ... }: {
  flake.modules.homeManager.nicoleCommon = {
    imports = [
      inputs.self.modules.homeManager.userCommon
      inputs.self.modules.homeManager.opencode
    ];

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
  };
}
