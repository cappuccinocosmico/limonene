{inputs, ...}: {
  flake.modules.nixos.users-nicole = {
    lib,
    config,
    pkgs,
    ...
  }: {
    limonene.defaultSession = lib.mkDefault "sway";
    nix.settings.trusted-users = ["nicole"];

    users.users.nicole = {
      isNormalUser = true;
      description = "Nicole";
      extraGroups = ["networkmanager" "wheel" "docker"];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBfMZjr6H4oK3qSBTxjZrMZptWXdzYC6QV4bdS892Ls nicole@vermissian"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1tyFv2UbkAJMx2U6bp8OwRx5wMpK7/DxSslcPS0sWY nicole@incarnadine"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBQresTdgx3Se26QxvwD/S9SaCRCWL8dvZwZ6IM62b2 nicole@cheddar"
      ];
    };

    home-manager.users.nicole = {config, ...}: {
      imports = [
        inputs.self.modules.homeManager.userCommon
        inputs.self.modules.homeManager.opencode
      ];

      home.packages = with pkgs; [
        nodejs-slim
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
        mkp224o
      ];

      programs.git = {
        enable = true;
        lfs.enable = false;
        settings = {
          user.name = "Nicole Venner";
          user.email = "nvenner@protonmail.ch";
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      home.shellAliases = {
        nrs = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/limonene";
        nrb = "nixos-rebuild build --verbose --flake ${config.home.homeDirectory}/limonene";
        nrd = "nix build --dry-run ${config.home.homeDirectory}/limonene#nixosConfigurations.$(hostname).config.system.build.toplevel";
        nziina = ''eval "if set -q ZELLIJ; exit; else; eval (ssh-agent -c); /home/nicole/Documents/mycorrhizae/ziina/ziina -l 0.0.0.0:2222; end"'';
        ziina-sshget = ''set -x XDG_RUNTIME_DIR /run/user/1000 && set -x WAYLAND_DISPLAY wayland-1 && echo "ssh -p 2222 $ZELLIJ_SESSION_NAME@apiarist" | tee /dev/tty | wl-copy'';
      };

      home.sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
        SHELL = "${pkgs.fish}/bin/fish";
        GTK_THEME = "Arc-Dark";
        BROWSER = "firefox";
        PNPM_HOME = "$HOME/.binaries/pnpm";
      };

      home.sessionPath = ["$HOME/.binaries/pnpm"];

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

      home = {
        username = "nicole";
        homeDirectory = "/home/nicole";
        stateVersion = "25.05";
      };
    };
  };
}
