{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./system/default.nix
    ./temporary.nix
    inputs.home-manager.nixosModules.home-manager{
        home-manager.users = {
          nicole.imports = [
            ./home/nicole.nix
          ];
        };
      }
  ];
  users.users = {
    nicole = {
      initialPassword = "changedapassword";
      isNormalUser = true;
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "networkmanager" "wheel" "video" "entertain" "wireshark"];
      shell = pkgs.nushell;
    };
  };
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
