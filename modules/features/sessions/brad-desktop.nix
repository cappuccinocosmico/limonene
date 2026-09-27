{ inputs, ... }: {
  flake.modules.homeManager.brad-desktop = { config, pkgs, ... }: {
    imports = [
      inputs.self.modules.homeManager.desktopApps
      inputs.self.modules.homeManager.gaming
      inputs.self.modules.homeManager.music
      inputs.self.modules.homeManager.firefox
    ];

    home.packages = [ pkgs.bitwarden-desktop ];

    home.sessionVariables.TERMINAL = "kitty";
  };
}
