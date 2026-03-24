{ inputs, ... }: {
  flake.modules.homeManager.nicoleDesktop = {
    imports = with inputs.self.modules.homeManager; [
      nicoleLinux
      sway
      wallust
      desktopApps
      gaming
      music
      vscode
      firefox
      activitywatch
    ];

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
