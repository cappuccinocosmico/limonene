
{ inputs, lib, config, pkgs, ... }: {
  home.packages = with pkgs; let
    mylatex=texlive.combine {
      inherit (texlive)  scheme-medium
      # Math
      tikz-cd
      pgfplots
      ntheorem
      thmtools
      svg
      listings # Code Blocks
      cleveref
      titlesec
      fourier
      # Bibtex
      biblatex 
      biblatex-mla biblatex-apa
      # Nice Stuff
      draftwatermark
      comment
      lipsum
      emoji
      # Book Stuff
      epigraph
      exercise
      background
      everypage
      eso-pic
      wallpaper
      # Mystery shit
      mparhack
      trimspaces
      transparent
      # Beamer
      beamerdarkthemes
    ;
    };
  in [
    mylatex
    biber
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
    go-swag
    sqlc
    goose
    air
  ];
}
