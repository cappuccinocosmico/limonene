{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      gnucash
      chessx
      # experimental youtube client
      # grayjay
      # ABSOLUTELY ESSENTIAL DO NOT DELETE
      duplicati
      # ----------
      # Experiments
      vlc
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
      signal-desktop
      slack
      zoom-us
      # Networking Stuff
      syncthing
      warp
      # Shell Stuff
      # textpieces # Text manipulation tool
      baobab # disk usage analyzer
# disabled since it might be requiring a huge manual build of webkitgtk
      # bookworm # yet another ebook reader
      koreader # Another Ebook Reader, mostly for embedded
      gnome-font-viewer
      gnome-terminal
      gnome-text-editor
      # diebahn # Train table viewer 
      # linphone # VOIP softphone
      # Music
      gimp
      # libreoffice-still
      postman
  ];
}
