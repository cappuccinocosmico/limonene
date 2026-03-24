{ ... }: {
  flake.modules.homeManager.activitywatch = { pkgs, ... }: {
    services.activitywatch = {
      enable = true;
      watchers.aw-watcher-window-wayland = {
        package = pkgs.aw-watcher-window-wayland;
      };
    };
  };
}
