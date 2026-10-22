{ inputs, ... }: {
  flake.modules.homeManager.sway = { lib, pkgs, config, ... }: let
    # Wraps a swayidle action so it is skipped while a game streaming session
    # is active. Steam Remote Play and Moonlight/Sunshine stream the
    # *composited* output, and sway stops compositing while an output is
    # powered down — XWayland games then stall on present and throttle to
    # ~1fps, turning the stream into a slideshow or a black screen. Steam
    # creates the `steam-streaming-playback` null sink for the duration of a
    # Remote Play session and sunshine creates `sink-sunshine-stereo`, so a
    # matching sink means someone is watching right now.
    unlessStreaming = name: script:
      pkgs.writeShellScript name ''
        if ${pkgs.pulseaudio}/bin/pactl list short sinks 2>/dev/null \
            | ${pkgs.gnugrep}/bin/grep -qE 'steam-streaming-playback|sink-sunshine'; then
          exit 0
        fi
        ${script}
      '';
  in {
    config = {
      home.packages = with pkgs; [
        wlogout
        wireplumber
        wl-clipboard
        wtype
        wev
        swaybg
        wlsunset
        sway-contrib.grimshot
        mako
        mpc
        bemenu
        fuzzel
        tofi
        pwvucontrol
      ];

      programs.wlogout = {
        enable = true;
        layout =
          (lib.optionals (!config.limonene.machineBehaviors.disableSleep.enable) [
            {
              label = "suspend";
              action = "systemctl suspend";
              text = "Suspend";
              keybind = "u";
            }
            {
              label = "hibernate";
              action = "systemctl hibernate";
              text = "Hibernate";
              keybind = "h";
            }
          ])
          ++ [
            {
              label = "reboot";
              action = "systemctl reboot";
              text = "Reboot";
              keybind = "r";
            }
            {
              label = "lock";
              action = "loginctl lock-session";
              text = "Lock";
              keybind = "l";
            }
            {
              label = "shutdown";
              action = "systemctl poweroff";
              text = "Shutdown";
              keybind = "s";
            }
            {
              label = "logout";
              action = "loginctl terminate-user $USER";
              text = "Logout";
              keybind = "e";
            }
          ];
      };

      programs.waybar = {
        enable = true;
        systemd.enable = true;
      };

      # Waybar's style.css @imports the wallust-generated colors file; make sure
      # it exists (using the fallback when no wallpaper has been applied yet) so
      # waybar never fails to start on a fresh machine.
      systemd.user.services.waybar = lib.mkIf (config.limonene.wallust.ensureColorsBin != null) {
        Service.ExecStartPre = [config.limonene.wallust.ensureColorsBin];
      };

      xdg.configFile = {
        "waybar/style.css".source = ./waybar/style.css;
        "waybar/assets/nix.svg".source = ./waybar/nix.svg;
      };

      services.swayidle = {
        enable = !config.limonene.machineBehaviors.disableSleep.enable
          || config.limonene.machineBehaviors.turnOffDisplay.enable;
        timeouts =
          (lib.optionals config.limonene.machineBehaviors.turnOffDisplay.enable [
            {
              timeout = 300;
              command = "${unlessStreaming "swayidle-dpms-off" ''
                exec ${pkgs.sway}/bin/swaymsg 'output * dpms off'
              ''}";
              resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
            }
          ])
          ++ (lib.optionals (!config.limonene.machineBehaviors.disableSleep.enable) [
            {
              timeout = 600;
              command = "${unlessStreaming "swayidle-suspend" ''
                exec ${pkgs.systemd}/bin/systemctl suspend
              ''}";
            }
          ]);
      };

      services.polkit-gnome.enable = true;

      systemd.user.targets.sway-session = {
        Unit = {
          Description = "sway compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };
  };
}
