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
# 2026-10-07: bumped a3c5fad -> 6fcf25b (Caddy runs under the applier).
{
  description = "Fortress configuration (amon-sul)";
  inputs.cococoir.url = "github:ElementalPlaneOfAir/cococoir/6fcf25bb64c1ae7b44b151262eb9b18cc0e319d6";
  outputs = {cococoir, ...}: {
    systemConfigs.fortress = cococoir.lib.mkFortressSystemConfig ({...}: {
      imports = [ ./config.nix ];
      nixpkgs.hostPlatform = "x86_64-linux";
      fortress.secrets.sopsFile = ./secrets/secrets.enc.yaml;
    });
  };
}
