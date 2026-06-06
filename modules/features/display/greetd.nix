{inputs, ...}: {
  flake.modules.nixos.display-greetd = {
    config,
    lib,
    pkgs,
    ...
  }: {
    services.displayManager.sddm.enable = lib.mkForce false;
    environment.pathsToLink = [ "/share/wayland-sessions" ];

    security.pam.services.greetd.enableGnomeKeyring = true;

    services.greetd = {
      enable = true;
      settings =
        {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions /run/current-system/sw/share/wayland-sessions";
          };
        }
        // lib.optionalAttrs (config.limonene.autologinUser != null && config.limonene.defaultSession != null) {
          initial_session = {
            command = config.limonene.defaultSession;
            user = config.limonene.autologinUser;
          };
        };
    };
  };
}
