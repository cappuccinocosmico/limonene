{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # OSS Games
    gnome.gnome-mines
    gnome.gnome-sudoku
    minetest
    # Stores Removed for incompatibility reasons
    # steam
    # heroic
    # Minecraft
    prismlauncher
  ];
}
