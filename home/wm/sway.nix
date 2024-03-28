{ inputs, lib, config, pkgs, ... }: {
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
  ];
  programs.foot = {
    enable = true;
  };
  wayland.windowManager.sway = {
   enable = true;
   config = rec {
    modifier = "Mod1";
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
     "XF86AudioRaiseVolume" =  "exec pamixer -i 5";
     "XF86AudioLowerVolume" = "exec pamixer -d 5";
     "XF86AudioMute" = "exec pamixer -t";
     "XF86MonBrightnessDown" = "exec light -U 5";
     "XF86MonBrightnessUp" = "exec light -A 5";
     "XF86AudioPlay" = "exec mpc toggle -q";
     # Awful Hack to fix the fact that seeking is broken
     "XF86AudioNext" = "exec mpc -q seek +5% && mpc toggle -q && mpc toggle -q";
     "XF86AudioPrev" = "exec mpc -q seek -5% && mpc toggle -q && mpc toggle -q";
     "Print" = "exec grimshot copy area";
     "${mod}+q" = "kill";
    };

   };
   extraSessionCommands="light -N .1";
   extraConfig = ''
input "2362:628:PIXA3854:00_093A:0274_Touchpad" {
    dwt enabled
    tap enabled
    middle_emulation enabled
}
output "*" bg ${config.home.homeDirectory}/.config/wallpaper/johannes-plenio-DKix6Un55mw-unsplash.jpg fill
seat seat0 xcursor_theme default 48
output eDP-1 scale 1
exec mako'';
  };
  programs.waybar = {
    enable = true;   
  };
  xdg.configFile = {
    "waybar/config".source = hypr-waybar/config.json;
	  "waybar/style.css".source = hypr-waybar/style.css;
	  "waybar/assets/nix.svg".source = hypr-waybar/nix.svg;
  };
  /*
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = ''swaymsg "output * dpms off"''; }
      { timeout = 600; command = "systemctl suspend"; }
    ];
    events = [
      { event = "after-resume"; command = ''swaymsg "output * dpms on"''; }
# Doesnt Recognize pasword and locks out of computer:
#      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock"; }
#      { event = "lock"; command = "lock"; }
    ];
  };
  */
  programs.swaylock.settings = {};
}
