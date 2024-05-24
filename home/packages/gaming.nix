{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # OSS Games
    gnome.gnome-mines
    gnome.gnome-sudoku
    minetest
    airshipper # Veloren Launcher
    # Stores
    steam
    heroic

  ];
}
