{ inputs, ... }: {
  flake.modules.nixos.common = { lib, ... }: {
    options.limonene = {
      machineType = lib.mkOption {
        type = lib.types.enum [ "desktop" "server" ];
        default = "desktop";
      };
      autologinUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      defaultSession = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };
}
