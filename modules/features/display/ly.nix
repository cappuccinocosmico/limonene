{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake.modules.nixos.display.ly = { config, lib, ... }: {
    services.displayManager.ly = {
      enable = true;
      settings = lib.mkMerge [
        (lib.mkIf (config.limonene.autologinUser != null && config.limonene.defaultSession != null) {
          auto_login_user = config.limonene.autologinUser;
          auto_login_session = config.limonene.defaultSession;
        })
      ];
    };
  };
}
