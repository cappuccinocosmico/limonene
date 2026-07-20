{inputs, ...}: {
  flake.modules.homeManager.languages = {pkgs, ...}: {
    home.packages = with pkgs; [
      (inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.whisperx)
      ffmpeg
      # nix language development stuff:
      mcp-nixos

      # JavaScript/TypeScript
      tailwindcss
      pnpm

      # Julia
      julia

      # Python
      uv
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
