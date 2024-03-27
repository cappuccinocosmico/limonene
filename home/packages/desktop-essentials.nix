{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      # Games
      gnome.gnome-mines
      gnome.gnome-sudoku
      graphite-gtk-theme
      # Experiments
      vlc
      firefox 
      vscodium-fhs 
      gnome.nautilus
      
      

  ];
}
