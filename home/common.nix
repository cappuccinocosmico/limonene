{ ... }: {
  imports = [
    ./common/shells.nix
    ./common/nvim.nix
    ./common/cli-tools.nix
    ./common/languages.nix
    ./common/git.nix
    ./common/kitty.nix
    ./fonts.nix
  ];

  # Cross-platform session paths
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  programs.home-manager.enable = true;
}
