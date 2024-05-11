{ inputs, lib, config, pkgs,sops-nix, ... }: {
  environment.systemPackages = with pkgs;[
    docker-compose
  ];
  users.extraGroups.docker.members = [ "nicole" ];
  virtualisation = {
    docker = {
      enable = true;
    };
    waydroid.enable = true;
  };
  services = {
    flatpak.enable = true;
    tailscale.enable = true;
    openssh = {
      enable = true;
    }; 
    pipewire = {
      enable = true;
      alsa.enable = true ;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true ;
      wireplumber.enable = true;
    };
    printing.enable = true;
  };
  sound ={
    enable = true;
    extraConfig = "options snd-hda-intel model=dell-headset-multi";
  };
  hardware.opengl ={
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime 
      intel-compute-runtime # Framework Computer
    ];
  };
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # Printing stuff

}
