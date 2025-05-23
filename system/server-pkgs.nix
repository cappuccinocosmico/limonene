{ inputs, lib, config, pkgs, ... }: {
  environment.systemPackages = with pkgs;[
    zellij
    bat # cat but actually adds formatting stuff 
    dua # disk usage but actually useful
    btop
    zoxide
  ];
}
