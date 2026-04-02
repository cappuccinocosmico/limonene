{ inputs, ... }: {
  flake.modules.homeManager.productivity = { ... }: {
    imports = [
      inputs.self.modules.homeManager.dailyRitual
      inputs.self.modules.homeManager.productivityDaemon
      inputs.self.modules.homeManager.activitywatch
    ];

    config = { };
  };
}
