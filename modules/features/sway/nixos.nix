{ inputs, ... }: {
  flake.modules.nixos.sway = { pkgs, ... }: {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    services.flatpak.enable = true;
  };
}
