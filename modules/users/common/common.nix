{inputs, ...}: {
  flake.modules.homeManager.userCommon = {
    imports = with inputs.self.modules.homeManager; [
      nodejs-slim
      shells
      cliTools
      languages
      kitty
      fonts
      neovim
    ];

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];

    programs.home-manager.enable = true;
  };
}
