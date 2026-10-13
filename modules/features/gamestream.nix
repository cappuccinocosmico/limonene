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
      settings.encoder = "vaapi";
    };

    environment.systemPackages = [pkgs.wlr-randr];

    users.users.nicole.extraGroups = ["video" "render"];
  };
}
