{...}: {
  flake.modules.nixos.gamestream = {
    pkgs,
    ...
  }: {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        # Autodetect picks XDG-portal capture on sway, which fails (no
        # RemoteDesktop portal on wlroots) and then no encoder probes
        # clean. KMS needs capSysAdmin (set above) and works on Wayland.
        capture = "kms";
        encoder = "vaapi";
        # Navi 33 (renderD128); renderD129 is the Raphael iGPU.
        adapter_name = "/dev/dri/renderD128";
      };
    };

    environment.systemPackages = [pkgs.wlr-randr];

    users.users.nicole.extraGroups = ["video" "render"];
  };
}
