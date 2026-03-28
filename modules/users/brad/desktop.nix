{ inputs, ... }: {
  flake.modules.homeManager.bradDesktop = { pkgs, config, ... }: {
    imports = with inputs.self.modules.homeManager; [
      bradCommon
      linuxCommon
      desktopApps
      gaming
      music
      firefox
    ];

    home.packages = with pkgs; [
      zed-editor
      gnucash
      octaveFull
    ];

    home.sessionVariables = {
      TERMINAL = "kitty";
    };

    home = {
      username = "brad";
      homeDirectory = "/home/brad";
    };
  };
}
