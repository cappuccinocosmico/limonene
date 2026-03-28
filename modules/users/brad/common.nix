{ inputs, ... }: {
  flake.modules.homeManager.bradCommon = { config, ... }: {
    imports = with inputs.self.modules.homeManager; [
      shells
      cliTools
      languages
      kitty
      fonts
      neovim
    ];

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

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];

    programs.home-manager.enable = true;

    home.stateVersion = "25.05";
  };
}
