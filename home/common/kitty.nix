{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "VictorMono Nerd Font";
      font_size = 20;
      background_opacity = "0.8";
      background = "#000000";
    };
  };
}
