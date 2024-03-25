{ inputs, lib, config, pkgs,sops-nix, ... }: {
  networking.networkmanager.enable = true;
  users.groups.entertain.gid = 4269;
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  networking.firewall = {
    allowedUDPPorts = [ 2234 ];
  };
  nixpkgs.config.allowUnfree = true;
  security.polkit.enable = true;
  programs.kdeconnect= {
    enable = true;
  };
  
  /*
  if test (id --user nicole) -ge 1000 && test (tty) = "/dev/tty1"
    Hyperland | wl-copy
  end */
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  fonts= {
    enableDefaultPackages=true;
    packages = with pkgs;[
    nerdfonts
    # (nerdfonts.override { fonts = ["3270" "FiraCode" "DroidSansMono" "Monofur" "VictorMono" "HeavyData" ]; })
    dejavu_fonts
    monocraft
    ];
    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu" ];
      };
    };
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  # IPFS File System, go implementation is named Kubo

}
