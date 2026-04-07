{...}: {
  flake.modules.homeManager.thunderbird = {pkgs, ...}: {
    programs.thunderbird = {
      enable = true;
    };
  };
}
