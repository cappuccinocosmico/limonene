{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      graphite-gtk-theme
      # Experiments
      vlc
      mpv
      firefox 
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
  ];
}
