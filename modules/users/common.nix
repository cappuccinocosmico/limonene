{ inputs, ... }: {
  flake.modules.nixos.common = { lib, config, ... }: {
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
      machineBehaviors = lib.mkOption {
        type = lib.types.submodule {
          options.disableSleep = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether the machine should never suspend or sleep";
            };
          };
          options.turnOffDisplay = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to turn off the display after inactivity to save power";
            };
          };
        };
        default = {};
      };
    };

    config = lib.mkMerge [
      {
        boot.kernelParams = lib.mkIf config.limonene.machineBehaviors.disableSleep.enable [
          "systemd.mask=sleep.target"
          "systemd.mask=suspend.target"
          "systemd.mask=hibernate.target"
          "systemd.mask=hybrid-sleep.target"
          "systemd.mask=suspend-then-hibernate.target"
        ];
      }
      (lib.mkIf config.limonene.machineBehaviors.disableSleep.enable {
        home-manager.sharedModules = [
          {
            limonene.machineBehaviors.disableSleep.enable = true;
          }
        ];
      })
      (lib.mkIf config.limonene.machineBehaviors.turnOffDisplay.enable {
        home-manager.sharedModules = [
          {
            limonene.machineBehaviors.turnOffDisplay.enable = true;
          }
        ];
      })
    ];
  };
}
