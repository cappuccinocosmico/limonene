{...}: {
  flake.modules.homeManager.desktopApps = {pkgs, ...}: {
    services.kdeconnect.enable = true;

    home.packages = with pkgs; [
      # Star shit
      stellarium

      # Acounting
      gnucash

      # Chess
      chessx
      chess-tui
      stockfish

      # ABSOLUTELY ESSENTIAL DO NOT DELETE
      duplicati
      # ----------
      # Experiments
      transmission_4-gtk
      zotero
      ungoogled-chromium
      tor-browser
      nicotine-plus
      vscodium-fhs
      nautilus
      # Audio
      vlc
      mpv
      easyeffects
      # Recording
      obs-studio
      audacity
      # Messaging
      signal-desktop
      slack
      zoom-us
      fractal # matrix client
      # Networking Stuff
      syncthing
      warp
      # Clipboard tools for Wine/Wayland integration
      wl-clipboard-x11 # provides xclip compatibility for Wine apps
      # Gnome apps
      baobab # disk usage analyzer
      komikku # ebook reader
      gnome-font-viewer
      gnome-terminal
      gnome-text-editor
      gimp
    ];
  };
}
