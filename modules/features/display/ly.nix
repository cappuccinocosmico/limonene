{inputs, ...}: {
  flake.modules.nixos.display-ly = {
    config,
    lib,
    ...
  }: {
    security.pam.services.ly.startSession = true;
    services.displayManager.ly = {
      enable = true;
      settings = lib.mkIf (config.limonene.autologinUser != null && config.limonene.defaultSession != null) {
        auto_login_user = config.limonene.autologinUser;
        auto_login_session = config.limonene.defaultSession;
      };
    };
  };
}
