
{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    packages/desktop-essentials.nix
    packages/browser.nix
    packages/server-essentials.nix
    packages/gaming.nix
    packages/music.nix
    packages/shells.nix
    packages/nvim.nix
    packages/languages.nix
  ];
}

