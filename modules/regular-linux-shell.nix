{ pkgs, ... }:

let
  # Cypress dependencies for GUI testing
  cypressDeps = with pkgs; [
    # libgtk2.0-0t64
    gtk2
    
    # libgtk-3-0t64
    gtk3
    
    # libgbm-dev
    mesa
    
    # libnotify-dev
    libnotify
    
    # libnss3
    nss
    nss.dev
    
    # libxss1
    # libXScrnSaver
    
    # libasound2t64
    alsa-lib
    
    # libxtst6
    # libXtst
    
    # xauth and xvfb
    xorg.xauth
    xorg.xvfb

    glib
    glib.dev
  ];
in

pkgs.buildFHSEnv {
  name = "rl";
  
  targetPkgs = pkgs: (with pkgs; [
    # Core development tools
    gcc
    glibc
    glibc.dev
    
    # Essential C libraries and headers
    pkg-config
    cmake
    gnumake
    
    # Standard C library extensions commonly needed for Rust
    openssl
    openssl.dev
    zlib
    zlib.dev
    
    # Networking and crypto libraries
    curl
    curl.dev
    libssh2
    libssh2.dev
    
    # Database libraries
    sqlite
    sqlite.dev
    postgresql
    postgresql.dev
    
    # System libraries
    systemd
    systemd.dev
    dbus
    dbus.dev
    glib
    glib.dev
    
    # Graphics and GUI libraries (for GUI Rust apps)
    xorg.libX11
    xorg.libX11.dev
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    mesa
    # mesa.dev
    vulkan-headers
    vulkan-loader
    
    # Audio libraries
    alsa-lib
    alsa-lib.dev
    
    # Compression libraries
    bzip2
    bzip2.dev
    xz
    xz.dev
    lz4
    lz4.dev
    
    # Math libraries
    gsl
    lapack
    blas
    
    # Additional commonly needed libraries
    libffi
    libffi.dev
    ncurses
    ncurses.dev
    readline
    readline.dev
    
    # Python (often needed for build scripts)
    python3
    python3Packages.pip
    
    # Git for version control
    git
  ]) ++ cypressDeps;
  
  multiPkgs = pkgs: with pkgs; [
    # 32-bit compatibility libraries (useful for some C extensions)
    glibc_multi
    gcc_multi
  ];
  
  runScript = "fish";
  
  profile = ''
    export CC=gcc
    export CXX=g++
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib/pkgconfig:/usr/share/pkgconfig"
    export CPATH="/usr/include"
    export LIBRARY_PATH="/usr/lib:/lib"
    export LD_LIBRARY_PATH="/usr/lib:/lib"
    
    # Rust-specific environment variables
    export RUST_BACKTRACE=1
    export CARGO_NET_GIT_FETCH_WITH_CLI=true
    
    echo "Rust FHS Development Environment"
    echo "==============================="
    echo "Available tools: gcc, pkg-config, cmake, git"
    echo "C libraries: openssl, zlib, sqlite, postgresql, curl, and more"
    echo "Run 'rustc --version' and 'cargo --version' to verify Rust installation"
    echo ""
  '';
}
