{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.beets = {
    enable = false;
    settings = {
      "plugins" = "inline convert web embedart beetcamp discogs spotify";
      "convert" = {
        "copy_album_art" = "yes";
      };
    };
  };
}
