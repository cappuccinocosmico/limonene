{...}: {
  flake.modules.nixos.gaming = {
    programs.steam = {
      enable = true;
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
    ];
  };
}
