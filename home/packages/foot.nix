{ inputs, lib, config, pkgs, ... }:  {
  programs.foot  = {
    enable = true;
    settings.main.font = "Monoid Nerd Font:size=15";
    settings.colors.alpha=0.7;
    settings.colors.background="000000";
  };
}
