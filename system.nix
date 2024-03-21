{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./system/default.nix
    inputs.home-manager.nixosModules.home-manager{
        home-manager.users = {
          nicole.imports = [
            ./home/nicole.nix
          ];
        };
      }
  ];
  # Mobile Phone substitute:
  virtualisation.waydroid.enable = true;
  services.flatpak.enable = true;

  users.users = {
    nicole = {
      initialPassword = "changedapassword";
      isNormalUser = true;
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "networkmanager" "wheel" "video" "entertain" "wireshark"];
      shell = pkgs.nushell;
    };
  };
}
