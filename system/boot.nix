{ inputs, lib, config, pkgs, ... }: {
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ ];
    loader.efi = {
      canTouchEfiVariables = true;
    };
    loader.systemd-boot = {
      enable = true;
    };
    # Use the GRUB 2 boot loader.
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      enableCryptodisk = true;
      useOSProber = true;
    };
  };
  systemd.extraConfig = ''
  DefaultTimeoutStopSec=10s
  DefaultTimeoutStartSec=10s
'';
}
