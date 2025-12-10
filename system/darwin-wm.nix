{pkgs, ...}: {
  # Window management services for macOS

  services.yabai = {
    enable = true;

    config = {
      # Layout
      layout = "bsp";
      auto_balance = "on";

      # Gaps (matching sway: inner 4, outer 10)
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 4;

      # Mouse
      mouse_follows_focus = "on";
      focus_follows_mouse = "off";
      mouse_modifier = "alt";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      # Window appearance
      window_placement = "second_child";
      split_ratio = "0.50";
    };

    extraConfig = ''
      # Scripting addition (requires SIP partially disabled)
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      sudo yabai --load-sa

      # Create spaces (requires scripting addition)
      spaces=$(yabai -m query --spaces | jq length)
      while [ "$spaces" -lt 10 ]; do
        yabai -m space --create
        spaces=$((spaces + 1))
      done

      # Disable management for system apps
      yabai -m rule --add app="^System Preferences$" manage=off
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Karabiner-Elements$" manage=off
      yabai -m rule --add app="^Archive Utility$" manage=off
      yabai -m rule --add app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add app="^Alfred Preferences$" manage=off
      yabai -m rule --add app="^1Password$" manage=off

      # App assignments (similar to sway assigns)
      # Space 5: Browser
      yabai -m rule --add app="^Firefox$" space=5
      yabai -m rule --add app="^Safari$" space=5

      # Space 10: Communication
      yabai -m rule --add app="^Signal$" space=10
      yabai -m rule --add app="^VLC$" space=10

      echo "yabai configuration loaded"
    '';
  };

  services.skhd = {
    enable = true;

    skhdConfig = ''
      # skhd configuration
      # Modifier: alt (option key)
      # Matches sway keybindings where possible

      # Focus window (vim keys)
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # Move window (swap)
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east

      # Move window to space
      shift + alt - 1 : yabai -m window --space 1
      shift + alt - 2 : yabai -m window --space 2
      shift + alt - 3 : yabai -m window --space 3
      shift + alt - 4 : yabai -m window --space 4
      shift + alt - 5 : yabai -m window --space 5
      shift + alt - 6 : yabai -m window --space 6
      shift + alt - 7 : yabai -m window --space 7
      shift + alt - 8 : yabai -m window --space 8
      shift + alt - 9 : yabai -m window --space 9
      shift + alt - 0 : yabai -m window --space 10

      # Focus space
      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      alt - 6 : yabai -m space --focus 6
      alt - 7 : yabai -m space --focus 7
      alt - 8 : yabai -m space --focus 8
      alt - 9 : yabai -m space --focus 9
      alt - 0 : yabai -m space --focus 10

      # Switch between adjacent workspaces
      alt - left : yabai -m space --focus prev
      alt - right : yabai -m space --focus next

      # Window operations
      alt - q : yabai -m window --close
      alt - f : yabai -m window --toggle zoom-fullscreen
      shift + alt - space : yabai -m window --toggle float

      # Layout
      alt - e : yabai -m space --layout bsp
      alt - s : yabai -m space --layout stack

      # Resize
      alt - r : yabai -m space --balance

      # Split direction
      alt - v : yabai -m window --insert south
      alt - b : yabai -m window --insert east

      # Applications
      alt - return : open -na kitty
      alt - d : open -a "Spotlight"

      # Restart yabai
      shift + alt - r : yabai --restart-service
    '';
  };

  services.spacebar = {
    enable = false;

    config = {
      position = "top";
      height = 26;
      title = "on";
      spaces = "on";
      clock = "on";
      power = "on";
      padding_left = 20;
      padding_right = 20;
      spacing_left = 25;
      spacing_right = 15;

      text_font = ''"Hack Nerd Font:Regular:12.0"'';
      icon_font = ''"Hack Nerd Font:Regular:12.0"'';

      background_color = "0xff202020";
      foreground_color = "0xffa8a8a8";
      space_icon_color = "0xff458588";
      power_icon_color = "0xffcd950c";
      battery_icon_color = "0xffd75f5f";
      dnd_icon_color = "0xffa8a8a8";
      clock_icon_color = "0xffa8a8a8";

      space_icon_strip = "1 2 3 4 5 6 7 8 9 10";
      power_icon_strip = " ";
      space_icon = "•";
      clock_icon = "";
      dnd_icon = "";
      clock_format = ''"%d/%m/%y %R"'';
    };

    extraConfig = ''
      echo "spacebar configuration loaded"
    '';
  };
}
