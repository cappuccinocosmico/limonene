{ ... }: {
  flake.modules.homeManager.music = { pkgs, ... }: {
    programs.beets = {
      enable = true;
      package = pkgs.python3.pkgs.toPythonApplication (pkgs.python3.pkgs.beets.override {
        pluginOverrides = {
          beetcamp = {
            enable = true;
            propagatedBuildInputs = [ pkgs.python3.pkgs.beetcamp ];
          };
        };
      });
      settings = {
        "plugins" = "inline convert web embedart bandcamp discogs spotify";
        "convert" = {
          "copy_album_art" = "yes";
        };
      };
    };
  };
}
