{inputs, ...}: {
  flake.modules.homeManager.nicoleSway = {
    lib,
    pkgs,
    config,
    ...
  }: let
    caffeine-toggle = pkgs.writeShellScriptBin "caffeine-toggle" ''
      if systemctl --user is-active --quiet swayidle; then
        systemctl --user stop swayidle
        echo 'systemctl --user start swayidle' | at now + 2 hours
        echo "☕"
      else
        systemctl --user start swayidle
        echo "💤"
      fi
    '';

    caffeine-status = pkgs.writeShellScriptBin "caffeine-status" ''
      if systemctl --user is-active --quiet swayidle; then
        echo "💤"
      else
        echo "☕"
      fi
    '';

    clipboard-type = pkgs.writeShellScriptBin "clipboard-type" ''
      ${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.wtype}/bin/wtype -
    '';
  in {
    imports = [inputs.self.modules.homeManager.sway];

    home.packages = [caffeine-toggle caffeine-status clipboard-type];

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      config = rec {
        assigns = {
          "10" = [
            {class = "vlc";}
            {app_id = "vlc";}
          ];
          "9" = [
            {class = "Signal";}
            {app_id = "signal";}
            {class = "Thunderbird";}
            {app_id = "thunderbird";}
          ];
          "8" = [
            {class = "element-desktop";}
            {class = "easyeffects";}
            {app_id = "com.github.wwmm.easyeffects";}
          ];
          "5" = [
            {app_id = "firefox";}
            {class = "firefox";}
          ];
        };
        output = {
          eDP-1 = {};
        };
        startup = [
          {command = "daily-ritual --gate";}
          {command = "${pkgs.wl-clipboard-x11}/bin/wl-clipboard-x11";}
          {command = "swaymsg 'workspace 1; exec kitty --single-instance'";}
          {command = "swaymsg 'workspace 5; exec firefox'";}
          {command = "swaymsg 'workspace 8; exec easyeffects'";}
          {command = "swaymsg 'workspace 8; exec element-desktop'";}
          {command = "swaymsg 'workspace 9; exec signal-desktop'";}
          {command = "swaymsg 'workspace 9; exec thunderbird'";}
          {command = "swaymsg 'workspace 10; exec vlc'";}
        ];
        modes = {
          negative = {
            "XF86AudioPlay" = "exec mpc toggle -q";
            "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
            "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioNext" = "exec mpc -q seek +5% && mpc toggle -q && mpc toggle -q";
            "XF86AudioPrev" = "exec mpc -q seek -5% && mpc toggle -q && mpc toggle -q";
            "Mod1+n" = "exec kitty --class pomodoro-panel -e ${config.limonene.productivity.productivityBin}/bin/productivity panel";
            "Mod1+Shift+Escape" = "mode default, exec ${config.limonene.productivity.productivityBin}/bin/productivity pomodoro cancel";
          };
          ritual = {
            "Mod1+Shift+Escape" = "mode default, exec daily-ritual --skip";
          };
        };
        modifier = "Mod1";
        terminal = "kitty --single-instance";
        menu = "fuzzel";
        gaps.inner = 4;
        gaps.outer = 10;
        bars = [];
        keybindings = let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
          lib.mkOptionDefault {
            "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
            "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
            "${mod}+equal" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
            "${mod}+minus" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86MonBrightnessDown" = "exec brightnessctl -n 1 set 5%-";
            "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
            "XF86AudioPlay" = "exec mpc toggle -q";
            "XF86AudioNext" = "exec mpc -q seek +5% && mpc toggle -q && mpc toggle -q";
            "XF86AudioPrev" = "exec mpc -q seek -5% && mpc toggle -q && mpc toggle -q";
            "Print" = "exec grimshot savecopy area";
            "Ctrl+Print" = "exec grimshot savecopy active";
            "${mod}+q" = "kill";
            "${mod}+Right" = "workspace next";
            "${mod}+Left" = "workspace prev";
            "${mod}+p" = "exec wlogout";
            "Ctrl+Shift+${mod}+v" = "exec clipboard-type";
            "${mod}+g" = "exec ${config.limonene.productivity.productivityBin}/bin/productivity goals toggle-interactive";
            "${mod}+Shift+g" = "exec kitty --class daily-goals-add -e ${config.limonene.productivity.productivityBin}/bin/productivity goals add-interactive";
            "${mod}+n" = "exec kitty --class pomodoro-panel -e ${config.limonene.productivity.productivityBin}/bin/productivity panel";
          };
      };
      extraConfig = ''
        input "1267:13037:ELAN0130:00_04F3:32ED_Touchpad" {
          dwt enabled
          tap enabled
          middle_emulation enabled
        }
        input "1:1:AT_Translated_Set_2_keyboard" {
          events disabled
        }
        seat seat0 xcursor_theme default 48
        output eDP-1 scale 1
        for_window [app_id="daily-ritual"] fullscreen enable
        for_window [app_id="daily-goals-add"] floating enable, resize set 800 100
        for_window [app_id="pomodoro-panel"] floating enable, resize set 700 350
        exec mako
        exec random-wallpaper

        exec_always ${pkgs.writeShellScript "check-4k-display" ''
          external_4k=$(${pkgs.sway}/bin/swaymsg -t get_outputs -r | ${pkgs.jq}/bin/jq -r '.[] | select(.name != "eDP-1") | select(.current_mode.width >= 3840 and .current_mode.height >= 2160) | .name')

          if [ -n "$external_4k" ]; then
            ${pkgs.sway}/bin/swaymsg output eDP-1 disable
          else
            ${pkgs.sway}/bin/swaymsg output eDP-1 enable
          fi
        ''}
      '';
    };

    programs.waybar.settings = [
      {
        layer = "top";
        position = "top";
        height = 50;
        "margin-top" = 8;
        "margin-right" = 8;
        "margin-left" = 8;
        "modules-left" = ["tray" "sway/workspaces"];
        "modules-center" = ["clock" "custom/pomodoro" "custom/goals"];
        "modules-right" = ["backlight" "pulseaudio" "network" "custom/caffeine" "battery"];

        "sway/workspaces" = {
          format = "{name} {windows}";
          "disable-click" = true;
          "format-window-separator" = " ";
          "window-rewrite-default" = "";
          "window-rewrite" = {
            "class<kitty>" = "";
            "class<foot>" = "";
            "class<element>" = "󰘨";
            "class<Element>" = "󰘨";
            "class<thunderbird>" = "";
            "class<Thunderbird>" = "";
            "class<firefox>" = "󰈹";
            "class<Firefox>" = "󰈹";
            "class<signal>" = "󰭹";
            "class<Signal>" = "󰭹";
            "class<vlc>" = "󰕼";
            "class<easyeffects>" = "󰓃";
            "class<com.github.wwmm.easyeffects>" = "󰓃";
            "class<code>" = "󰨞";
            "class<Code>" = "󰨞";
            "class<thunar>" = "";
            "class<Thunar>" = "";
            "class<nautilus>" = "";
            "class<Nautilus>" = "";
            "class<discord>" = "󰙯";
            "class<Discord>" = "󰙯";
          };
        };

        "custom/nix" = {
          format = " ";
          "on-click" = "fuzzel";
        };

        "custom/song" = {
          format = "{}";
          exec = "playerctl metadata -f '{{markup_escape(title)}} - {{markup_escape(artist)}}' -F";
          "on-click" = "playerctl play-pause";
        };

        tray = {};

        backlight = {
          format = "{percent}% {icon}";
          "format-icons" = ["" "" "" "" "" "" "" "" "" "" "" "" "" ""];
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          "format-muted" = "🔇";
          "format-icons" = {default = ["󰕿" "󰖀" "󰕾"];};
          "ignored-sinks" = ["Easy Effects Sink"];
        };

        mpd = {
          format = "▶ : {album} - {title}";
          "format-paused" = "⏸ : {album} - {title}";
        };

        "custom/goals" = {
          format = "{}";
          exec = "${config.limonene.productivity.productivityBin}/bin/productivity goals waybar";
          "on-click" = "${config.limonene.productivity.productivityBin}/bin/productivity goals toggle-interactive";
          interval = 10;
          "return-type" = "json";
        };

        "custom/pomodoro" = {
          format = "{}";
          exec = "${config.limonene.productivity.productivityBin}/bin/productivity pomodoro waybar";
          "on-click" = "kitty --class pomodoro-panel -e ${config.limonene.productivity.productivityBin}/bin/productivity panel";
          interval = 1;
          "return-type" = "json";
        };

        "custom/caffeine" = {
          format = "{}";
          exec = "${caffeine-status}/bin/caffeine-status";
          "on-click" = "${caffeine-toggle}/bin/caffeine-toggle";
          interval = 5;
        };

        network = {
          "format-wifi" = "{essid} {icon}";
          "format-icons" = ["󰤟" "󰤢" "󰤥" "󰤨"];
          "format-ethernet" = "󰈀";
          "format-disconnected" = "";
        };
        battery = {
          format = "{capacity}% {icon}";
          "format-full" = "{capacity}% 󱟢";
          "format-charging" = "{capacity}% 󰂄";
          "format-plugged" = "{capacity}% 󰂃"; # plugged, charging or below full-at threshold
          "format-icons" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂"];
          "full-at" = 90; # treat ≥90% as "full" — triggers format-full when plugged & not actively charging
          states = {
            warning = 40;
            critical = 20;
          };
          "on-click" = "wlogout";
        };

        clock = {
          interval = 1;
          format = "{:%H:%M:%S}  ";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "on-click-right" = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {"on-click-right" = "mode";};
        };
      }
    ];

    services.swayidle.events = {
      "after-resume" = "random-wallpaper; sleep 2; ${config.limonene.productivity.dailyRitual}/bin/daily-ritual --gate";
    };
  };
}
