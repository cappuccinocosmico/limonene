{pkgs, ...}: {
  home.packages = with pkgs; [
    # JabbaScript
    nodejs_22
    tailwindcss
    # python shit
    uv
    # rust-analyzer
    # Maybe included in rustup
    # rustup
    corepack
    pipx
    black
    prettierd
    # poetry
    # Extra Git stuff
    git-town
    git-filter-repo
    # Nixos Bs
    steam-run
    # Browser stuff
    zig # C alternative
    # ruff-lsp # Rust based python lsp
    pyright # Another python lsp
    # SQL Viewer
    dbeaver-bin
    # Proofs
    elan
    jdk
    lua
    # Go Ecosystem
    go
    # goose
    air
  ];
}
