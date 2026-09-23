{
  description = "Smells Strongly of Oranges";

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };

    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:NixOS/nixos-hardware";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spacebar = {
      url = "github:cmacrae/spacebar/v1.4.0";
      # No nixpkgs follows: spacebar v1.4.0 uses darwin.apple_sdk, which was
      # removed in nixpkgs 26.05; its own pinned nixpkgs still provides it.
    };

    import-tree = {
      url = "github:vic/import-tree";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vpn-confinement = {
      url = "github:Maroka-chan/VPN-Confinement";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The cococoir ("fortress") home-server product, consumed as a
    # module set (nixosModules.default) plus its pkgs factory
    # (lib.mkPkgs). Deliberately does NOT follow limonene's nixpkgs:
    # the product pins nixos-unstable for its service versions
    # (e.g. Jellyfin 12), and lib.mkPkgs carries the jellarr/crane
    # build wiring the modules require. Only the barebones amon-sul
    # machine imports it; no other limonene module depends on it.
    cococoir = {
      url = "github:ElementalPlaneofAir/cococoir";
    };
  };
}
