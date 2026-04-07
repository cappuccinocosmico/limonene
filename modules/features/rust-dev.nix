{ inputs, lib, ... }: {
  # System-level native library deps so -sys crates can find headers/pkg-config
  # from any terminal without a per-project dev shell.
  flake.modules.nixos.rustDev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      openssl.dev
      zlib.dev
      pkg-config
    ];

    environment.variables = {
      PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" (with pkgs; [
        openssl
        zlib
      ]);
      # openssl-sys respects these even when pkg-config is unavailable
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
    };

    # Make openssl/zlib available for pre-built binaries (cargo binstall targets etc.)
    programs.nix-ld.libraries = with pkgs; [
      openssl
      zlib
    ];
  };

  # User-level stable Rust toolchain via rust-overlay.
  # For nightly in a specific project, add a rust-toolchain.toml — rust-overlay
  # picks it up automatically in devShells. To switch this global install to
  # nightly, replace rust-bin.stable.latest.default with
  # pkgs.rust-bin.nightly.latest.default below.
  flake.modules.homeManager.rustDev = { pkgs, ... }: {
    home.packages = [
      (pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      })
      pkgs.cargo-binstall
    ];
  };
}
