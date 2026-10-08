# Fortress configuration — amon-sul.
#
# The magic folder's flake (lives at /etc/fortress/config on the box). It
# composes config.nix + the sealed secrets with the fortress modules, and
# `fortress-apply` builds `systemConfigs.fortress.unitsDir` from it at run
# time — never through nixos-rebuild (ADR-035).
#
# `cococoir` is pinned to the exact rev the machine flake uses (see
# limonene's flake.lock) so machine and app build the same cococoir.
# Bootstrap generates a `main`-tracking flake; this replaces it.
# 2026-10-07: bumped 6fcf25b -> d46a656 (Caddy binds the wildcard;
# the tunnel ingress moved to :8080/:8443).
{
  description = "Fortress configuration (amon-sul)";
  inputs.cococoir.url = "github:ElementalPlaneOfAir/cococoir/d46a656ffaef4cf231844b404b39a7bec55b1c5b";
  outputs = {cococoir, ...}: {
    systemConfigs.fortress = cococoir.lib.mkFortressSystemConfig ({...}: {
      imports = [ ./config.nix ];
      nixpkgs.hostPlatform = "x86_64-linux";
      fortress.secrets.sopsFile = ./secrets/secrets.enc.yaml;
    });
  };
}
