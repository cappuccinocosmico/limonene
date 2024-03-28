{ inputs, lib, config, pkgs, ... }:  {
  programs.foot  = {
    enable = true;
    settings.main.font = "monocraft:size=15";
    settings.colors.alpha=0.7;
    settings.colors.background="000000";
  };
}
