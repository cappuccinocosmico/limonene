{...}: {
  flake.modules.homeManager.desktopApps = {lib, pkgs, ...}: let
    bosl2 = pkgs.stdenv.mkDerivation {
      pname = "openscad-bosl2";
      version = "2.0.752";
      src = pkgs.fetchzip {
        url = "https://github.com/BelfrySCAD/BOSL2/archive/refs/tags/v2.0.752.tar.gz";
        sha256 = "0raaj1i9lnnd9q7bci815pr96dsjridpwa1xkczlbcx128qn0yw0";
      };
      installPhase = ''
        mkdir -p $out/BOSL2
        cp -r $src/* $out/BOSL2/
      '';
    };
  in {
    services.kdeconnect.enable = true;

    # Expose BOSL2 to OpenSCAD via its user library path
    # (OpenSCAD resolves ~/.local/share/OpenSCAD/libraries first).
    xdg.dataFile."OpenSCAD/libraries/BOSL2" = {
      source = "${bosl2}/BOSL2";
    };

    home.packages = with pkgs; [
      libreoffice
      # E Readers
      thorium-reader
      # USB Bootstick Makers
      popsicle
      impression
      # 3d Printing & CAD
      prusa-slicer
      orca-slicer
      # pkgs.unstable.orca-slicer
      freecad
      openscad
      # Android debugger:
      android-tools
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
      easyeffects
      mpv
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
      gnome-sudoku
      baobab # disk usage analyzer
      komikku # ebook reader
      gnome-font-viewer
      gnome-terminal
      gnome-text-editor
      gimp
    ];
  };
}
