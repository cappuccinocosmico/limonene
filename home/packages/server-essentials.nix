{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [
    kompose # docker compose to Kubernetes converter 
    kubernetes-helm
    # Terminal Utils
    tmux
    gh # Github CLI
    yt-dlp
    age
    pciutils
    parted
    exfat
    btop
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
    networkmanager
    nettools
    # Tor hidden services stuff 
    mkp224o
    viu # image viewing in terminal
  ];
}
