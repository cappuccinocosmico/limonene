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
# 2026-10-08: bumped d46a656 -> 8aedf1b (HTTPS scoped to the clearnet
# domain; the LAN plane is a :80 plain-HTTP catch-all).
# 2026-10-09: bumped 8aedf1b -> 92dc01b (secrets sealed in the store;
# `fortress.secrets.sopsFile` below is now required, not optional).
{
  description = "Fortress configuration (amon-sul)";
  inputs.cococoir.url = "github:ElementalPlaneOfAir/cococoir/6424cfdb59f2d96951b7b105b2aec17a2efe1fbc";
  outputs = {cococoir, ...}: {
    systemConfigs.fortress = cococoir.lib.mkFortressSystemConfig ({...}: {
      imports = [ ./config.nix ];
      nixpkgs.hostPlatform = "x86_64-linux";
      fortress.secrets.sopsFile = ./secrets/secrets.enc.yaml;
    });
  };
}
