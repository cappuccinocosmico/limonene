{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      graphite-gtk-theme
      # Experiments
      vlc
      deadbeef
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
      zoom-us
      # Networking Stuff
      syncthing
      warp
      # Shell Stuff
      fish
      # textpieces # Text manipulation tool
      baobab # disk usage analyzer
      foliate # ebook reader
      calibre # ebook thing
      gnome.gnome-font-viewer
      diebahn # Train table viewer 
  ];
}
