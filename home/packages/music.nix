{ inputs, lib, config, pkgs, ... }:  {
    programs.beets ={
      enable = true;
      settings = {
        "plugins" = "inline convert web embedart beetcamp discogs spotify";
        "convert" = {
          "copy_album_art" = "yes";
        };
      };
    };
}
