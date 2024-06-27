{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      graphite-gtk-theme
      # Experiments
      vlc
      deadbeef
      mpv
      librewolf # For use with i2p
      firefox 
      ungoogled-chromium
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
      gnome-text-editor
      neovim-gtk
      # diebahn # Train table viewer 
      cyberchef
      # linphone # VOIP softphone
      calls
      jami
      # Music
      vcv-rack
  ];
}
