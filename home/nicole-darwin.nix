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
  };

  home.sessionPath = [
    "$HOME/.binaries/pnpm"
  ];

  home = {
    username = "nicole";
    homeDirectory = "/Users/nicole";
  };

  # yabai and skhd configuration (binaries installed via Homebrew)
  xdg.configFile = {
    "yabai/yabairc" = {
      source = ./wm/yabai/yabairc;
      executable = true;
    };
    "skhd/skhdrc".source = ./wm/yabai/skhdrc;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
