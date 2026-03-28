{ inputs, ... }: {
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake.modules.nixos.users.brad = { lib, config, pkgs, ... }: let
    ssh_keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaOgK4fO5gTB79Infge2b+31VzXnC23lqV7m5NA+xuz bvenner@proton.me"
    ];
  in {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      inputs.self.modules.nixos.common
    ];

    config = lib.mkMerge [
      {
        limonene.defaultSession = lib.mkDefault "plasma";

        nix.settings.trusted-users = [ "brad" ];

        users.users.brad = {
          isNormalUser = true;
          description = "Brad";
          extraGroups = [ "networkmanager" "wheel" "docker" ];
          shell = pkgs.fish;
          openssh.authorizedKeys.keys = ssh_keys;
        };

        home-manager.users.brad = { config, ... }: {
          imports = [
            inputs.self.modules.homeManager.userCommon
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

          programs.git = {
            enable = true;
            lfs.enable = false;
            settings = {
              user = {
                name = "bvenner";
                email = "bvenner@proton.me";
              };
              github = {
                user = "bvenner";
              };
              init.defaultBranch = "main";
              pull.rebase = true;
            };
          };

          home.shellAliases = {
            nrs = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/limonene";
            nrb = "nixos-rebuild build --verbose --flake ${config.home.homeDirectory}/limonene";
          };

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

          home = {
            username = "brad";
            homeDirectory = "/home/brad";
            stateVersion = "25.05";
          };
        };
      }
      (lib.mkIf (config.limonene.machineType == "desktop") {
        imports = [
          inputs.self.modules.nixos.plasma
          inputs.self.modules.nixos.display.ly
        ];

        home-manager.users.brad = {
          imports = [
            inputs.self.modules.homeManager.desktopApps
            inputs.self.modules.homeManager.gaming
            inputs.self.modules.homeManager.music
            inputs.self.modules.homeManager.firefox
          ];

          home.sessionVariables.TERMINAL = "kitty";
        };
      })
    ];
  };
}
