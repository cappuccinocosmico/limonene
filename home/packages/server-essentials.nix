{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminal Utils
    tmux
    lshw
    age
    pciutils
    parted
    exfat
    btop
    pv # pipe viewer??
    zip
    wget
    lazygit
    # Neofetch Clones
    neofetch
    # Crypto and Stuff
    gnupg
    git-crypt
    # Server web browser
    elinks
    git
    exfat
    exfatprogs
    dig
    hugo
    tailscale
    trayscale
    speedtest-cli
    nushell
    btop
    keepassxc
    # audio
    pavucontrol
    helvum
    # utils
    pandoc
  ];
}
