{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
      graphite-gtk-theme
      # Experiments
      vlc
      firefox 
      vscodium-fhs 
      gnome.nautilus
      # Messaging
      signal-desktop
  ];
}
