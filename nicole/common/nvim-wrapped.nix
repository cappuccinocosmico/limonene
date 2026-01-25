{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ripgrep
    ripgrep-all
    chafa
    # TypeScript language server (needed for manual TS LSP config)
    nodePackages.typescript-language-server
    nodePackages.typescript
    # SOPS CLI tool (required for sops.nvim)
    sops
  ];

  # New nvf configuration
  programs.nvf = {
    enable = true;
    settings = import ./nvim.nix {inherit inputs lib config pkgs;};
  };

  programs.micro = {
    enable = true;
  };
}
