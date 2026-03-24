{ inputs, ... }: {
  flake.modules.homeManager.bradDesktop = { pkgs, config, ... }: {
    imports = with inputs.self.modules.homeManager; [
      bradCommon
      desktopApps
      gaming
      music
      firefox
    ];

    home.packages = with pkgs; [
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

      zed-editor
      gnucash
      octaveFull
    ];

    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      SHELL = "${pkgs.fish}/bin/fish";
      GTK_THEME = "Arc-Dark";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      PNPM_HOME = "$HOME/.binaries/pnpm";
    };

    home.sessionPath = [
      "$HOME/.binaries/pnpm"
    ];

    home = {
      username = "brad";
      homeDirectory = "/home/brad";
    };

    xdg = {
      systemDirs.data = [ "${pkgs.gsettings-desktop-schemas}/share" ];
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
