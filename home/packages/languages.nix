
{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; [

    # JabbaScript
    nodejs_22
    tailwindcss
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
    cypress
    julia
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
