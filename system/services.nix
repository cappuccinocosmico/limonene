{ inputs, lib, config, pkgs,sops-nix, ... }: {
  environment.systemPackages = with pkgs;[
    podman-compose
  ];
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    waydroid.enable = true;
  };
  services = {
    flatpak.enable = true;
    tailscale.enable = true;
    openssh = {
      enable = true;
    }; 
    services.pipewire = {
      enable = true;
      alsa.enable = true ;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true ;
      wireplumber.enable = true;
    };
    printing.enable = true;
    avahi.enable = true;
    avahi.nssmdns = true;
    avahi.openFirewall = true;
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
