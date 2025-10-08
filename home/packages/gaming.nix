{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # OSS Games
    gnome-mines
    gnome-sudoku
    # minetest
    # Stores Removed for incompatibility reasons
    # steam
    # heroic
    # Minecraft
    prismlauncher
  ];
}
