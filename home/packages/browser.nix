{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # or inputs.zen-browser.homeModules.twilight
    # or inputs.zen-browser.homeModules.twilight-official
  ];

  programs.zen-browser.enable = true;
}
