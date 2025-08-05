{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      # ABSOLUTELY ESSENTIAL DO NOT DELETE
      duplicati
      # ----------
      # Experiments
      vlc
      deadbeef
      mpv
      transmission_4-gtk
      zotero
      # firefox 
      ungoogled-chromium
      tor-browser
      nicotine-plus
      vscodium-fhs 
      nautilus
      # Audio
      easyeffects
      # Recording
      obs-studio
      audacity
      # Messaging
      # signal-desktop
      slack
      zoom-us
      # Networking Stuff
      syncthing
      warp
      # Shell Stuff
      # textpieces # Text manipulation tool
      baobab # disk usage analyzer
      bookworm # yet another ebook reader
      koreader # Another Ebook Reader, mostly for embedded
      calibre # ebook thing
      gnome-font-viewer
      gnome-terminal
      gnome-text-editor
      # diebahn # Train table viewer 
      # linphone # VOIP softphone
      calls
      # Music
      vcv-rack
      gimp
      libreoffice-still
      postman
  ];
}
