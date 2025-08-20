{ inputs, lib, config, pkgs, ... }:  {
  home.packages = with pkgs; [
    ripgrep
    ripgrep-all
  ];
  programs.micro = {
    enable = true;
  };
}
