{ inputs, ... }: {
  flake.modules.homeManager.activitywatch = { pkgs, lib, config, ... }: {
    config = {
      services.activitywatch = {
        enable = true;
        watchers.aw-watcher-window-wayland = {
          package = pkgs.aw-watcher-window-wayland;
        };
      };

      systemd.user.services.activitywatch-watcher-aw-watcher-window-wayland = {
        Unit = {
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.mkForce "${pkgs.aw-watcher-window-wayland}/bin/aw-watcher-window-wayland";
        };
      };
    };
  };
}
