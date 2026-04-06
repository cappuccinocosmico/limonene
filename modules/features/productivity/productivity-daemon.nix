{ inputs, ... }: {
  flake.modules.homeManager.productivityDaemon = { pkgs, lib, config, ... }:
    let
      productivityTs = ./. + "/_productivity.ts";

      # Both scripts inject full store paths so the TypeScript can call external
      # tools (swaymsg, fuzzel, notify-send) without needing them on PATH.
      mkScript = name: extraArgs: pkgs.writeShellApplication {
        inherit name;
        runtimeEnv = {
          SWAYMSG     = "${pkgs.sway}/bin/swaymsg";
          FUZZEL      = "${pkgs.fuzzel}/bin/fuzzel";
          NOTIFY_SEND = "${pkgs.libnotify}/bin/notify-send";
        };
        text = ''
          exec ${pkgs.bun}/bin/bun run ${productivityTs} ${extraArgs} "$@"
        '';
      };

      productivity-bin        = mkScript "productivity"        "";
      productivity-daemon-bin = mkScript "productivity-daemon" "--daemon";
    in
    {
      options.limonene.productivity.productivityBin = lib.mkOption {
        type    = lib.types.package;
        default = productivity-bin;
      };

      config = {
        home.packages = [ productivity-bin productivity-daemon-bin pkgs.bun ];

        systemd.user.services.productivity-daemon = {
          Unit = {
            Description = "Productivity daemon (pomodoro + goals)";
            After   = [ "graphical-session.target" ];
            PartOf  = [ "graphical-session.target" ];
          };
          Service = {
            Type            = "simple";
            ExecStart       = "${productivity-daemon-bin}/bin/productivity-daemon";
            PassEnvironment = "SWAYSOCK WAYLAND_DISPLAY";
            Restart         = "on-failure";
            RestartSec      = "2s";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
