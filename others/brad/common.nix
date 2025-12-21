# Common Configuration for Brad
#
# This file imports shared configurations from Nicole's setup.
# Brad gets the same powerful tools: shell, text editor, CLI tools, git, terminal, and fonts.
#
# If you want to customize any of these later, you can:
# 1. Copy the specific file from ../../nicole/common/ to this directory
# 2. Modify it to your liking
# 3. Update the import path below to point to your local copy
{...}: {
  # Import all common configurations from Nicole's setup

  imports = [
    ../../nicole/common/shells.nix
    ../../nicole/common/nvim-wrapped.nix
    ../../nicole/common/cli-tools.nix
    ../../nicole/common/languages.nix
    ../../nicole/common/git.nix
    ../../nicole/common/kitty.nix
    ../../nicole/fonts.nix
  ];

  # Cross-platform session paths
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  programs.home-manager.enable = true;
  # You can override or add to Nicole's settings here if needed
  # For example:
  # home.sessionPath = [ "$HOME/my-custom-bin" ] ++ config.home.sessionPath;
}
