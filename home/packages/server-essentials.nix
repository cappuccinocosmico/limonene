{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminal Utils
    tmux
    yt-dlp
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
    fastfetch
    # Crypto and Stuff
    gnupg
    git-crypt
    # Server web browser
    elinks
    git
    exfat
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
    # SSH annoyingness
    xterm
    gnome.gnome-terminal
    # mycor stuff
    thttpd
    nmtui
    
  ];
}
