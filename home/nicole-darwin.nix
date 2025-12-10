# macOS home-manager configuration for nicole
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Cross-platform configuration
    ./common.nix
  ];

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    PNPM_HOME = "$HOME/.binaries/pnpm";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  home.sessionPath = [
    "$HOME/.binaries/pnpm"
  ];

  home = {
    username = "nicole";
    homeDirectory = "/Users/nicole";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
