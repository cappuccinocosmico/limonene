{inputs, ...}: {
  flake.modules.homeManager.userCommon = {lib, ...}: {
    options.limonene.machineBehaviors.disableSleep = lib.mkOption {
      type = lib.types.submodule {
        options.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether this machine should never suspend or sleep";
        };
      };
      default = {};
    };

    imports = with inputs.self.modules.homeManager; [
      shells
      cliTools
      languages
      kitty
      fonts
      neovim
      rustDev
      thunderbird
    ];

    config = {
      home.sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
        "$HOME/go/bin"
      ];

      programs.home-manager.enable = true;
    };
  };
}
