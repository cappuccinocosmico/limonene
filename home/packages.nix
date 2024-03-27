
{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    packages/desktop-essentials.nix
    packages/gaming.nix
    packages/music.nix
    packages/nushell.nix
    packages/nvim.nix
    packages/foot.nix
  ];
}

