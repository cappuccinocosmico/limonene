{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # OSS Games
    gnome.gnome-mines
    gnome.gnome-sudoku
    minetest
    # Stores
    # steam
    heroic
    # Minecraft
    prismlauncher
  ];
}
