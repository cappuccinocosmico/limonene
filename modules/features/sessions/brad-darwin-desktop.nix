{...}: {
  flake.modules.homeManager.brad-darwin-desktop = {pkgs, ...}: {
    # Terminal-based desktop apps for macOS.
    # GUI apps are installed via Homebrew in modules/features/homebrew.nix.
    home.packages = with pkgs; [
      otel-cli
      libsixel
      yazi
    ];
  };
}
