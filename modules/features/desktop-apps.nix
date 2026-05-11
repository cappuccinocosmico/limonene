{...}: {
  flake.modules.homeManager.desktopApps = {pkgs, ...}: {
    services.kdeconnect.enable = true;

    home.packages = with pkgs; [
      # 3d Printing
      orca-slicer
      # Android debugger:
      android-tools
      # Star shit
      stellarium

      # Local AI Stuff:
      ollama-cpu

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
      easyeffects
      # Recording
      obs-studio
      audacity
      # Messaging
      signal-desktop
      slack
      zoom-us
      fractal # matrix
      element-desktop # Even more matrix
      cinny-desktop # Even Even More Matrix
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
