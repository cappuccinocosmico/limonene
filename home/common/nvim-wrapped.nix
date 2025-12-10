{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ripgrep
    ripgrep-all
    chafa
  ];

  # New nvf configuration
  programs.nvf = {
    enable = true;
    settings = import ./nvim.nix {inherit inputs lib config pkgs;};
  };

  programs.micro = {
    enable = true;
  };
}
