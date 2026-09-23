{inputs, ...}: {
  flake.modules.homeManager.neovim = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [inputs.nvf.homeManagerModules.default];

    home.packages = with pkgs; [
      ripgrep
      ripgrep-all
      chafa
      sops
      ghostscript_headless
    ];

    programs.nvf = {
      enable = true;
      settings = import ./_config.nix {inherit lib config pkgs;};
    };

    programs.micro = {
      enable = true;
    };
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.nvim =
      (inputs.nvf.lib.neovimConfiguration {
        modules = [./_config.nix];
        inherit pkgs;
      }).neovim;

    apps.default = {
      type = "app";
      program = "${self'.packages.nvim}/bin/nvim";
    };
  };
}
