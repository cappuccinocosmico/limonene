{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  wallpaper_path = "~/Pictures/wallpaper.jpg";
in {
  # You can import other home-manager modules here

  home.packages = with pkgs; [
    wireplumber
    # Sway DE Stuff
    wl-clipboard
    wev # Wayland Event Viewer
    swaybg # wallpaper
    wlsunset
    sway-contrib.grimshot # Screenshotting
    mako # Notifications
    # Other
    mpc
    # dmenu clones
    bemenu # cmd bemenu-run
    fuzzel
    tofi # cmd tofi-run
    foot
    pwvucontrol
  ];
  programs.fish.loginShellInit = "
  if test (tty) = '/dev/tty1'
    set -Ux XDG_CURRENT_DESKTOP sway
    set -Ux MOZ_ENABLE_WAYLAND 1
    /usr/bin/sway
  end
  ";
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      assigns = {
        "10" = [
          {class = "Signal";}
          {app_id = "signal";}
          {class = "vlc";}
          {app_id = "vlc";}
        ];
        "9" = [
          {class = "easyeffects";}
          {app_id = "com.github.wwmm.easyeffects";}
        ];
        "5" = [
          {app_id = "firefox";}
          {class = "firefox";}
        ];
      };
      output = {
        eDP-1 = {
          # bg = "~/.config/wallpaper/johannes-plenio-DKix6Un55mw-unsplash.jpg fill";
        };
      };
      startup = [
        {command = "light -N .1";}
        {command = "swaymsg 'workspace 1; exec kitty'";}
        {command = "swaymsg 'workspace 5; exec firefox'";}
        {command = "swaymsg 'workspace 9; exec easyeffects'";}
        {command = "swaymsg 'workspace 10; exec signal-desktop'";}
        {command = "swaymsg 'workspace 10; exec vlc'";}
      ];
      modifier = "Mod4";
      terminal = "kitty";
      menu = "fuzzel";
      gaps.inner = 4;
      gaps.outer = 10;
      bars = [
        {
          command = "waybar";
        }
      ];
      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          "${mod}+equal" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
          "${mod}+minus" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86MonBrightnessDown" = "exec light -U 5";
          "XF86MonBrightnessUp" = "exec light -A 5";
          "XF86AudioPlay" = "exec mpc toggle -q";
          # Awful Hack to fix the fact that seeking is broken
          "XF86AudioNext" = "exec mpc -q seek +5% && mpc toggle -q && mpc toggle -q";
          "XF86AudioPrev" = "exec mpc -q seek -5% && mpc toggle -q && mpc toggle -q";
          "Print" = "exec grimshot savecopy area";
          "Ctrl+Print" = "exec grimshot savecopy active";
          "${mod}+q" = "kill";
        };
    };
    # output "*" bg  fill
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
      exec mako
      exec swaybg -i ${wallpaper_path} -m fill

      # Disable laptop display if external 4K monitor is detected
      exec_always ${pkgs.writeShellScript "check-4k-display" ''
        # Check for external displays with 4K resolution (3840x2160 or higher)
        external_4k=$(${pkgs.sway}/bin/swaymsg -t get_outputs -r | ${pkgs.jq}/bin/jq -r '.[] | select(.name != "eDP-1") | select(.current_mode.width >= 3840 and .current_mode.height >= 2160) | .name')

        if [ -n "$external_4k" ]; then
          # External 4K display found, disable laptop screen
          ${pkgs.sway}/bin/swaymsg output eDP-1 disable
        else
          # No external 4K display, enable laptop screen
          ${pkgs.sway}/bin/swaymsg output eDP-1 enable
        fi
      ''}
    '';

    # exec LT="$lock_timeout" ST="$screen_timeout" LT=${LT:-300} ST=${ST:-60} && \
    #     swayidle -w \
    #     timeout $LT 'swaylock -f' \
    #     timeout $((LT + ST)) 'swaymsg "output * power off"' \
    #                   resume 'swaymsg "output * power on"'  \
    #     timeout $ST 'pgrep -xu "$USER" swaylock >/dev/null && swaymsg "output * power off"' \
    #          resume 'pgrep -xu "$USER" swaylock >/dev/null && swaymsg "output * power on"'  \
    #     before-sleep 'swaylock -f' \
    #     lock 'swaylock -f' \
    #     unlock 'pkill -xu "$USER" -SIGUSR1 swaylock'
    # output * background ${wallpaper_path} fill
  };
  programs.waybar = {
    enable = true;
  };
  xdg.configFile = {
    "waybar/config".source = waybar/config.json;
    "waybar/style.css".source = waybar/style.css;
    "waybar/assets/nix.svg".source = waybar/nix.svg;
  };
  # programs.swaylock.settings = {};
  # services.swayidle = {
  #     enable= true;
  #     timeouts= [
  #       {
  #         timeout = 600;
  #         command = "${pkgs.systemd}/bin/systemctl suspend";
  #       }
  #     ];
  #   };
}
