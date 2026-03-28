{ inputs, ... }: {
  flake.modules.homeManager.nicoleLinux = { pkgs, config, ... }: {
    imports = [ inputs.self.modules.homeManager.linuxCommon ];

    home.packages = with pkgs; [
      nodejs-slim
      mkp224o
    ];

    home.shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/limonene";
      nrb = "nixos-rebuild build --verbose --flake ${config.home.homeDirectory}/limonene";
      nrd = "nix build --dry-run ${config.home.homeDirectory}/limonene#nixosConfigurations.$(hostname).config.system.build.toplevel";
      nziina = ''eval "if set -q ZELLIJ; exit; else; eval (ssh-agent -c); /home/nicole/Documents/mycorrhizae/ziina/ziina -l 0.0.0.0:2222; end"'';
      ziina-sshget = ''set -x XDG_RUNTIME_DIR /run/user/1000 && set -x WAYLAND_DISPLAY wayland-1 && echo "ssh -p 2222 $ZELLIJ_SESSION_NAME@apiarist" | tee /dev/tty | wl-copy'';
    };

    home = {
      username = "nicole";
      homeDirectory = "/home/nicole";
    };
  };
}
