
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
    nodejs
    corepack
    uv
    pipx
    prettierd
    # python311Full
    python313Full
    poetry
    # Extra Git stuff
    git-town
    # Nixos Bs 
    steam-run
    # Browser stuff
    cypress
    julia
    zig # C alternative
    # SQL Viewer
    dbeaver-bin
    # Proofs
    elan
  ];
}
