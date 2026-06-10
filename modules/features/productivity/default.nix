{inputs, ...}: {
  flake.modules.homeManager.productivity = {pkgs, ...}: {
    imports = [
      inputs.self.modules.homeManager.activitywatch
    ];

    config = {
      home.packages = with pkgs; [
        planify
      ];
    };
  };
}
