{...}: {
  flake.modules.homeManager.languages = {pkgs, ...}: {
    home.packages = with pkgs; [
      # nix language development stuff:
      mcp-nixos

      # JavaScript/TypeScript
      tailwindcss
      pnpm

      # Julia
      julia

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
  };
}
