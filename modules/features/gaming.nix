{...}: {
  flake.modules.nixos.gaming = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      # Steam's X11 desktop capture cannot see the screen under a Wayland
      # compositor and it logs "WARNING: Desktop capture unavailable, try
      # running Steam with -pipewire", falling back to "Desktop Black Frame" —
      # a literal synthetic black screen — whenever it is not capturing a game
      # window through the overlay hook. -pipewire captures via
      # xdg-desktop-portal (xdg-desktop-portal-wlr on sway) instead.
      package = pkgs.steam.override {extraArgs = "-pipewire";};
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    hardware.graphics.enable32Bit = true;
  };

  flake.modules.homeManager.gaming = {pkgs, ...}: {
    home.packages = with pkgs; [
      gamescope
      gnome-mines
      gnome-sudoku
      prismlauncher

      pkgs.unstable.xmage
    ];
  };
}
