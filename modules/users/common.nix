{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake.modules.nixos.common = { lib, ... }: {
    options.limonene = {
      machineType = lib.mkOption {
        type = lib.types.enum [ "desktop" "server" ];
        default = "desktop";
        description = "Machine type determines which features are enabled (desktop gets GUI, server is CLI-only)";
      };

      autologinUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "User to automatically log in. Only works on desktop machines with ly enabled.";
      };

      defaultSession = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default session for autologin (e.g., 'sway', 'plasma')";
      };
    };
  };
}
