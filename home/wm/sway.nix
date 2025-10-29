{ inputs, lib, config, pkgs, ... }: 
let wallpaper_path = "~/Pictures/wallpaper.jpg"; in
{
  # You can import other home-manager modules here
  
  home.packages =  with pkgs; [
    wireplumber
    # Sway DE Stuff
    wl-clipboard
    wev # Wayland Event Viewer
    swaybg # wallpaper
    wlsunset
    sway-contrib.grimshot # Screenshotting
    mako # Notifications
    # Other
    mpc-cli
    # dmenu clones
    bemenu # cmd bemenu-run
    fuzzel
    tofi # cmd tofi-run
    foot
    pwvucontrol
  ];
  programs.foot = {
    enable = true;
    settings.main.font = "Dejavu Sans Mono:size=20";
    settings.colors.alpha=0.8;
    settings.colors.background="000000";
  };
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
        { class = "signal-desktop"; }
        { class = "vlc"; }
      ];
      "9" = [
        { class = "easyeffects"; }
      ];
    };
    output = {
        eDP-1 = {
          # bg = "~/.config/wallpaper/johannes-plenio-DKix6Un55mw-unsplash.jpg fill";
        };
      };
    startup = [
      { command = "light -N .1";}
      { command = "signal-desktop";}
      # { command = "slack";}
      { command = "easyeffects";}
      { command = "vlc";}
    ];
    modifier = "Mod4";
    terminal = "foot";
    menu = "fuzzel";
    gaps.inner = 4;
    gaps.outer = 10;
    bars = [{
     command = "waybar";
    }];
    keybindings = let
     mod = config.wayland.windowManager.sway.config.modifier;
    in  lib.mkOptionDefault {
     "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
     "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
     "${mod}+equal" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ --limit 1.0";
     "${mod}+minus" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
     "XF86AudioMute"        = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
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
