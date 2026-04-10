{...}: {
  flake.modules.homeManager.thunderbird = {pkgs, ...}: {
    home.packages = with pkgs; [
      protonmail-bridge
    ];
    services.protonmail-bridge = {
      enable = true;
    };
    programs.thunderbird = {
      enable = true;
    };
  };
}
