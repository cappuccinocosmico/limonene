{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      graphite-gtk-theme
      # Experiments
      vlc
      mpv
      firefox 
      ungoogled-chromium
      tor-browser
      nicotine-plus
      vscodium-fhs 
      gnome.nautilus
      # Audio
      easyeffects
      # Recording
      obs-studio
      audacity
      # Messaging
      signal-desktop
      # Networking Stuff
      syncthing
      warp
      # Shell Stuff
      fish
  ];
}
