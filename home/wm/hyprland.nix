
{ inputs, lib, config, pkgs, ... }: 
let wallpaper_path = "~/Pictures/wallpaper.jpg"; in
{
  # You can import other home-manager modules here
  
  home.packages =  with pkgs; [
    # Sway DE Stuff
    wl-clipboard
    wev # Wayland Event Viewer
    swaybg # wallpaper
    wlsunset
    sway-contrib.grimshot # Screenshotting
    swaylock
    mako # Notifications
    # Other
    mpc-cli
    # dmenu clones
    bemenu # cmd bemenu-run
    fuzzel
    tofi # cmd tofi-run
    foot
    pamixer # For volume control
    pwvucontrol
  ];
  programs.foot = {
    enable = true;
    settings.main.font = "Dejavu Sans Mono:size=20";
    settings.colors.alpha=0.8;
    settings.colors.background="000000";

  };
  # programs.fish.loginShellInit = "
  # if test (tty) = '/dev/tty1'
  #   set -Ux XDG_CURRENT_DESKTOP sway
  #   set -Ux MOZ_ENABLE_WAYLAND 1
  #   /usr/bin/sway
  # end
  # ";

  wayland.windowManager.hyprland = {
    enable = true;
    # Example hyperland config, go ahead and try to make the hyperland config as identical as possible to the sway config below:
#     extraConfig = ''
# $mod = ALT
# bind = $mod RETURN,,
#     '';
    settings = {
      decoration = {
        blur.enabled = false;
        shadow.enabled = false;
      };
      misc = {
        vfr = true;
      };

      "$mod" = "SUPER";
      "$terminal" = "foot";
      "$menu" = "fuzzel";

      # # Mouse movements
      # bindm = [
      #   "$mod, mouse:272, movewindow";
      #   "$mod, mouse:273, resizewindow";
      #   "$mod ALT, mouse:272, resizewindow";
      # ];
      #
      animation = [
        "global,0"
      ];
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $menu"
        "$mod, K, exec, grimshot copy area"
        "$mod, Q, killactive"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Keyboard bindings
      # bindm = [
      #   "XF86AudioRaiseVolume,exec,pamixer -i 2"
      #   "XF86AudioLowerVolume,exec,pamixer -d 2"
      #   "XF86AudioMute,exec,pamixer -t"
      #   "XF86MonBrightnessDown,exec,light -U 5"
      #   "XF86MonBrightnessUp,exec,light -A 5"
      #   "XF86AudioPlay,exec,mpc toggle -q"
      #   "XF86AudioNext,exec,mpc -q seek +5% && mpc toggle -q && mpc toggle -q"
      #   "XF86AudioPrev,exec,mpc -q seek -5% && mpc toggle -q && mpc toggle -q"
      #   "Print,exec,grimshot copy area"
      #   "ALT+q,killactive"
      #   "ALT+Return, exec, $terminal"
      #   "ALT+d,exec,fuzzel-run"
      # ];

      # Window rules: workspace assignments
      # windowrules = [
      #   "workspace=10;class=\"signal-desktop\""
      #   "workspace=10;class=\"vlc\""
      #   "workspace=9;class=\"easyeffects\""
      # ];

      # Gaps configuration
      # gaps = {
      #   inner = 4;
      #   outer = 10;
      # };

      # Autostart commands
      exec-once = [
        "light -N .1"
        # "signal-desktop"
        # "easyeffects"
        # "vlc"
        "waybar"
        # "mako"
      ];

      # Monitor settings
      monitor = [
        "eDP-1,2256x1504,0x0,1"  
      ];

      # Background (wallpaper)
      # background = {
      #   "eDP-1" = {
      #     path = wallpaper_path;
      #     mode = "fill";
      #   };
      # };

      # Cursor settings
      # cursor = {
      #   theme = "default";
      #   size = 48;
      # };

      # Input devices settings
      # input = {
      #   "2362:628:PIXA3854:00_093A:0274_Touchpad" = {
      #     dwt = true;
      #     tap = true;
      #     middle_emulation = true;
      #   };
      # };
    };
  };
  # REFERENCE SWAY CONFIG: try to copy and make the hyprland config as close to this as possible.
  programs.waybar = {
    enable = true;   
  };
  xdg.configFile = {
    "waybar/config".source = waybar/config.json;
	  "waybar/style.css".source = waybar/style.css;
	  "waybar/assets/nix.svg".source = waybar/nix.svg;
  };
  programs.swaylock.settings = {};
}
