{ inputs, lib, config, pkgs, ... }:  {
  home.packages = with pkgs; [
    ripgrep
    ripgrep-all
  ];
  programs.neovim = {
    enable = true;
      extraPackages = with pkgs; [
          parinfer-rust
          tree-sitter # to build grammars from source
          libgcc
      ];
    viAlias = true;
    vimAlias = true;
  };
  xdg.configFile."nvim" = {
    recursive = true;
    source = config/nvim;
  };
  programs.micro = {
    enable = true;
  }
}
