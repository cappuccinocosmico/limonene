{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Games
    gnome.gnome-mines
    gnome.gnome-sudoku
    # Steam
    steam
    heroic
  ];
}
