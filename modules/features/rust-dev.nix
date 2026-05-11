{
  inputs,
  lib,
  ...
}: let
  rustEnv = pkgs: {
    PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" (with pkgs; [
      openssl
      zlib
      fontconfig
      freetype
      expat
    ]);
    OPENSSL_DIR = "${pkgs.openssl.dev}";
    OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
  };
in {
  # System-level native library deps so -sys crates can find headers/pkg-config
  # from any terminal without a per-project dev shell.
  flake.modules.nixos.rustDev = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      openssl.dev
      zlib.dev
      fontconfig.dev
      freetype.dev
      expat.dev
      pkg-config
    ];

    environment.variables = rustEnv pkgs;

    # Make openssl/zlib available for pre-built binaries (cargo binstall targets etc.)
    programs.nix-ld.libraries = with pkgs; [
      openssl
      zlib
      fontconfig
      freetype
      expat
    ];
  };

  # User-level stable Rust toolchain via rust-overlay.
  # For nightly in a specific project, add a rust-toolchain.toml — rust-overlay
  # picks it up automatically in devShells. To switch this global install to
  # nightly, replace rust-bin.stable.latest.default with
  # pkgs.rust-bin.nightly.latest.default below.
  flake.modules.homeManager.rustDev = {pkgs, ...}: {
    home.packages = [
      (pkgs.rust-bin.nightly.latest.default.override {
        targets = ["wasm32-unknown-unknown"];
        extensions = ["rust-src" "rust-analyzer" "clippy" "rustfmt"];
      })
      pkgs.cargo-binstall
    ];

    home.sessionVariables = rustEnv pkgs;
  };
}
