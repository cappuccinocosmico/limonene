{ ... }: {
  flake.modules.homeManager.activitywatch = { pkgs, lib, ... }: {
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
      Service = {
        ExecStart = lib.mkForce "${pkgs.bash}/bin/sh -c 'sleep 15 && exec ${pkgs.aw-watcher-window-wayland}/bin/aw-watcher-window-wayland'";
      };
    };
  };
}
