{ ... }: {
  flake.modules.homeManager.activitywatch = { pkgs, ... }: {
    services.activitywatch = {
      enable = true;
      watchers.aw-watcher-window-wayland = {
        package = pkgs.aw-watcher-window-wayland;
      };
    };

    systemd.user.services.activitywatch-watcher-aw-watcher-window-wayland = {
      Unit = {
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
    };
  };
}
