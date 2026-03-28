{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake.modules.nixos.plasma = { ... }: {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;
  };
}
