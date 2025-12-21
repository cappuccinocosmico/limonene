{pkgs, ...}: {
  home.packages = with pkgs; [
    jq
    nmap
    sqlite

    # better cli tools
    dua # disk usage but actually useful
    xh # better curl
    hyperfine
    devenv

    just

    tmate # Backup remote terminal viewer

    kompose # docker compose to Kubernetes converter
    kubernetes-helm
    frp # Fast Reverse Proxy

    # Terminal Utils
    gh # Github CLI
    yt-dlp
    age
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
    dig
    hugo
    speedtest-cli
    nushell

    # utils
    pandoc
    viu # image viewing in terminal
  ];
}
