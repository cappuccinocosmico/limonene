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

  # User-level Rust toolchain via rust-overlay.
  #
  # Pinned to 1.95.0. Bumping to 1.96.0+ breaks the build with:
  #   "auto-patchelf could not satisfy dependency libz.so.1"
  #   wanted by libLLVM.so.22 / rust-lld
  # because rust-overlay's mk-component-set.nix only adds `zlib.dev` to
  # rustc's buildInputs, and the new LLVM 22 / rust-lld binaries link
  # against libz.so.1 at runtime. The runtime zlib must be in
  # auto-patchelf's library search path. (Hit 2026-06-09 on both
  # stable 1.96.0 and nightly 1.98.0.)
  #
  # To bump past 1.95, either wait for rust-overlay to fix the
  # libz issue upstream (re-check by running
  #   nix build --dry-run \
  #     nixpkgs#rust-bin.stable."1.96.0".default
  # and see if the rustc drv is in cache.nixos.org), or re-aggregate
  # the toolchain manually using `rust-overlay.lib.mkAggregated`
  # with a `rustc` component whose buildInputs include a symlinkJoin
  # of `pkgs.zlib` and `pkgs.zlib.dev`.
  #
  # See available versions at
  #   https://github.com/oxalica/rust-overlay/tree/7d5f8d75fc195a236b46633d7679139698aeb35f/manifests/stable
  #
  # Other notes:
  #   * NEVER use `rust-bin.nightly.latest.default` — the rust-overlay README
  #     warns it can fail when the very latest nightly manifest is missing a
  #     component. If you need nightly, use:
  #         pkgs.rust-bin.selectLatestNightlyWith (
  #           toolchain: toolchain.default.override { ... }
  #         )
  #   * For per-project nightly pinning, add a rust-toolchain.toml — it
  #     doesn't affect this global install.
  flake.modules.homeManager.rustDev = {pkgs, ...}: {
    home.packages = [
      # (pkgs.rust-bin.stable."1.95.0".default.override {
      #   targets = ["wasm32-unknown-unknown"];
      #   extensions = ["rust-src" "rust-analyzer" "clippy" "rustfmt"];
      # })
      pkgs.cargo-binstall
    ];

    home.sessionVariables = rustEnv pkgs;
  };
}
