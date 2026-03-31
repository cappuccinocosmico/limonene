{ inputs, ... }: {
  flake.modules.homeManager.nicoleSway = { lib, pkgs, config, ... }: let
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
    imports = [ inputs.self.modules.homeManager.sway ];

    home.packages = [ caffeine-toggle caffeine-status clipboard-type ];

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      config = rec {
        assigns = {
          "10" = [
            { class = "Signal"; }
            { app_id = "signal"; }
            { class = "vlc"; }
            { app_id = "vlc"; }
          ];
          "9" = [
            { class = "easyeffects"; }
            { app_id = "com.github.wwmm.easyeffects"; }
          ];
          "5" = [
            { app_id = "firefox"; }
            { class = "firefox"; }
          ];
        };
        output = {
          eDP-1 = {};
        };
        startup = [
          { command = "daily-ritual --gate"; }
          { command = "${pkgs.wl-clipboard-x11}/bin/wl-clipboard-x11"; }
          { command = "swaymsg 'workspace 1; exec kitty --single-instance'"; }
          { command = "swaymsg 'workspace 5; exec firefox'"; }
          { command = "swaymsg 'workspace 9; exec easyeffects'"; }
          { command = "swaymsg 'workspace 10; exec signal-desktop'"; }
          { command = "swaymsg 'workspace 10; exec vlc'"; }
        ];
        modes = {
          negative = {
            "XF86AudioPlay" = "exec mpc toggle -q";
            "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
            "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "XF86AudioNext" = "exec mpc -q seek +5% && mpc toggle -q && mpc toggle -q";
            "XF86AudioPrev" = "exec mpc -q seek -5% && mpc toggle -q && mpc toggle -q";
            "Mod1+n" = "exec kitty --class pomodoro-panel -e negative-pomodoro panel";
            "Mod1+Shift+Escape" = "mode default, exec negative-pomodoro cancel";
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
            "${mod}+g" = "exec daily-goals toggle";
            "${mod}+Shift+g" = "exec kitty --class daily-goals-add -e daily-goals-add-popup";
            "${mod}+n" = "exec kitty --class pomodoro-panel -e negative-pomodoro panel";
          };
      };
      extraConfig = ''
        exec "systemctl --user import-environment {,WAYLAND_}DISPLAY SWAYSOCK; systemctl --user start sway-session.target"
        exec swaymsg -t subscribe '["shutdown"]' && systemctl --user stop sway-session.target

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
        for_window [app_id="pomodoro-panel"] floating enable, resize set 500 200
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

    services.swayidle.events = {
      "after-resume" = "random-wallpaper && daily-ritual --gate";
    };
  };
}
