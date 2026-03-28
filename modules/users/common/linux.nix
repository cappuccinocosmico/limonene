{inputs, ...}: {
  flake.modules.homeManager.linuxCommon = {
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.self.modules.homeManager.userCommon];

    home.packages = with pkgs; [
      nodejs-slim
      nix-ld
      dconf
      mesa
      libdrm

      otel-desktop-viewer
      otel-cli
      imv
      libsixel
      pciutils
      parted
      exfat
      pavucontrol
      xterm
      networkmanager
      nettools

      steam-run
      dbeaver-bin
    ];

    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      SHELL = "${pkgs.fish}/bin/fish";
      GTK_THEME = "Arc-Dark";
      BROWSER = "firefox";
      PNPM_HOME = "$HOME/.binaries/pnpm";
    };

    home.sessionPath = [
      "$HOME/.binaries/pnpm"
    ];

    xdg = {
      systemDirs.data = ["${pkgs.gsettings-desktop-schemas}/share"];
      userDirs = {
        enable = true;
        createDirectories = true;
        music = "${config.home.homeDirectory}/Music";
        download = "${config.home.homeDirectory}/Downloads";
        documents = "${config.home.homeDirectory}/Documents";
        publicShare = "${config.home.homeDirectory}/Documents/public";
        templates = null;
      };
    };

    systemd.user.startServices = "sd-switch";

    home.stateVersion = "25.05";
  };
}
