{ inputs, ... }: {
  flake.modules.homeManager.nicole-desktop = { config, ... }: {
    imports = [
      inputs.self.modules.homeManager.nicoleSway
      inputs.self.modules.homeManager.wallust
      inputs.self.modules.homeManager.desktopApps
      inputs.self.modules.homeManager.gaming
      inputs.self.modules.homeManager.music
      inputs.self.modules.homeManager.vscode
      inputs.self.modules.homeManager.firefox
      inputs.self.modules.homeManager.productivity
      inputs.self.modules.homeManager.githubNotifications
    ];

    home.sessionVariables.TERMINAL = "kitty";
  };
}
