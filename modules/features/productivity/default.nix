{inputs, ...}: {
  flake.modules.homeManager.productivity = {pkgs, ...}: {
    imports = [
      inputs.self.modules.homeManager.dailyRitual
      inputs.self.modules.homeManager.productivityDaemon
      inputs.self.modules.homeManager.activitywatch
    ];

    config = {
      home.packages = with pkgs; [
        anytype
        planify
      ];
    };
  };
}
