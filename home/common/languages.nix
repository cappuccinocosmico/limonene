{pkgs, ...}: {
  home.packages = with pkgs; [
    # JavaScript/TypeScript
    nodejs_22
    tailwindcss
    corepack # includes pnpm, yarn

    # Python
    uv
    pipx
    black
    prettierd
    pyright

    # Extra Git stuff
    git-town
    git-filter-repo

    # Zig
    zig

    # Java
    jdk

    # Lua
    lua

    # Lean theorem prover
    elan

    # Go Ecosystem
    go
    air
  ];
}
