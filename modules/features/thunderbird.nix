{...}: {
  flake.modules.homeManager.thunderbird = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [pkgs.protonmail-bridge];
    services.protonmail-bridge = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };
    programs.thunderbird = {
      enable = true;
    };
  };
}
