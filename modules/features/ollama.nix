{inputs, ...}: {
  flake.modules.nixos.ollama = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
    };

    # services.ollama.rocmOverrideGfx can be set per-machine if ROCm doesn't
    # auto-detect your AMD GPU. For example:
    #   services.ollama.rocmOverrideGfx = "10.3.0";  # gfx1031
    # Run `nix run nixpkgs#rocmPackages.rocminfo -- rocminfo | grep gfx` to find your target.
  };
}
