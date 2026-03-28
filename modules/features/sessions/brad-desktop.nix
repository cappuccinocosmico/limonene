{ inputs, ... }: {
  flake.modules.homeManager.brad-desktop = { config, ... }: {
    imports = [
      inputs.self.modules.homeManager.desktopApps
      inputs.self.modules.homeManager.gaming
      inputs.self.modules.homeManager.music
      inputs.self.modules.homeManager.firefox
    ];

    home.sessionVariables.TERMINAL = "kitty";
  };
}
