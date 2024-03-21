{ inputs, lib, config, pkgs,sops-nix, ... }: {
  services.openssh = {
    enable = true;
  }; 
  services.tailscale.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true ;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true ;
    wireplumber.enable = true;
  };
  sound ={
    enable = true;
    extraConfig = "options snd-hda-intel model=dell-headset-multi";
  };
  services.upower={
    enable = true;
    percentageAction = 7;
    criticalPowerAction = "HybridSleep";
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
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

}