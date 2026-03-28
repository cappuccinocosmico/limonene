{ inputs, ... }: {
  flake.modules.homeManager.sway = { lib, pkgs, ... }: {
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
      layout = [
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

    xdg.configFile = {
      "waybar/config".source = ./waybar/config.json;
      "waybar/style.css".source = ./waybar/style.css;
      "waybar/assets/nix.svg".source = ./waybar/nix.svg;
    };

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 600;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };

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
}
