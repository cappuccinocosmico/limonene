{ inputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    inputs.hardware.nixosModules.framework-12th-gen-intel
    inputs.hardware.nixosModules.common-pc-ssd
    # Import your generated (nixos-generate-config) hardware configuration
    ./scans/apiarist-hardware-configuration.nix
    # And other modules that serve specific designated purposes

    # Home manager config for this specific machine.
    inputs.home-manager.nixosModules.home-manager{
    
      # settings.main.dpi-aware = "no";
      home-manager.users.nicole.programs.nushell.loginFile.text = ''
        if (tty) == "/dev/tty1" {
          sway
        }
      ''; 
    }
  ];
  environment.systemPackages = with pkgs; [

  ];




  # Time Zone
  time.timeZone="America/Denver";
  # Hostname and Networking.
  networking = {
    hostName = "apiarist";
  };
  
  services.getty.autologinUser="nicole";
  boot.initrd.secrets = {
   "/crypto_keyfile.bin" = null;
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  programs.light.enable=true;
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";



  
}

