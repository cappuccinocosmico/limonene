# /etc/fortress/config/config.nix — amon-sul's fortress APP config.
#
# The faithful migration target for the box: everything the old all-in-one
# config carried in its `fortress.*` block, moved into the stateful folder
# (ADR-037). See README.md beside this file for the full picture.
#
# ============================================================================
# NOT DEPLOYABLE AS-IS. The applier is a dex+caddy vertical slice today:
#
#   * `jellyfin`, `jellarr`, `radarr`, `sonarr`, `qbittorrent`, `seerr` are
#     stubs in nix/system-manager/host-shim.nix and hard-fail if enabled.
#   * The applier installs only `systemd/system` from the closure
#     (nix/system-manager/apply.sh), so `environment.etc` files are never
#     written and `tmpfiles.d` is never applied.
#
# Each block is marked [applier-ready] or [blocked: <reason>].
# ============================================================================
{
  ...
}: {
  # ── Exposure ────────────────────────────────────────────────────────
  # [applier-ready]
  fortress.baseDomain = "fractal.interdim.net";
  fortress.tls.mode = "acme";
  fortress.network.lanAddress = "192.168.0.7";

  # ── Storage ─────────────────────────────────────────────────────────
  # [applier-ready] The HOST owns the btrfs pool and mounts it at /media
  # (machine flake). The app writes plain dirs under dataRoot.
  fortress.storage = {
    backend = "plain-dirs";
    dataRoot = "/media";
  };

  # ── Services ────────────────────────────────────────────────────────
  fortress.services = {
    # [applier-ready] dex is the always-on OIDC provider.
    dex.enable = true;
    dex.public = true;

    # [blocked: host-shim stub + jellarr module not on the applier path]
    # jellyfin = {
    #   enable = true;
    #   public = true;
    #   mediaRoot = "/media/entertain";
    # };

    # [blocked: host-shim stub; enables radarr+sonarr+qbittorrent+seerr]
    # media.enable = true;

    # cryptpad/forgejo were `public = true` with no `enable = true` on the
    # old box — never running. Left off; flip `enable = true` when graduated.
  };

  # ── OIDC accounts ───────────────────────────────────────────────────
  # [applier-ready] bcrypt hashes carried verbatim from the pre-migration
  # config.
  services.dex.settings.staticPasswords = [
    {
      email = "nicole@fractal.interdim.net";
      hash = "$2b$10$ab2woi0QuI5sczAk3Wg1EOtdh9DgGQjUF9YyKhKIBu9UOmn1G0Dmu";
      username = "nicole";
      userID = "00000000-0000-0000-0000-000000000001";
      groups = ["admins"];
    }
    {
      email = "brad@fractal.interdim.net";
      hash = "$2b$10$lBlef1v6je65.nf8h5kud..ChUot1RV1EMAVVdlBHQ.bhSqID5A0y";
      username = "brad";
      userID = "00000000-0000-0000-0000-000000000002";
      groups = ["users"];
    }
  ];

  # ── Tunnel client (ADR-025) ─────────────────────────────────────────
  # [blocked: the applier does not install environment.etc, so the
  #  client's /etc/fortress-client.json would never be written]
  # services.fortress-client.enable = true;
  # environment.etc."fortress-client.json".text = builtins.toJSON {
  #   tunnel = {
  #     ip = "10.10.0.3";
  #     prefix = 24;
  #     edge_pubkey = "lX+5lGEF1qDJEag13Kymyxy/SJH63LPxKTvMg50WE2E=";
  #     edge_endpoint = "62.238.111.21:51820";
  #     edge_allowed_ips = "10.10.0.0/24";
  #   };
  #   forwards = [
  #     { listen_addr = "10.10.0.3:80"; proto = "tcp"; dest_addr = "127.0.0.1:80"; }
  #     { listen_addr = "10.10.0.3:443"; proto = "tcp"; dest_addr = "127.0.0.1:443"; }
  #   ];
  # };
  # # One-time copy of the legacy wg identity; without it the client
  # # generates a key the edge has never registered.
  # systemd.services.fortress-legacy-wg-key = {
  #   wantedBy = ["fortress-client.service"];
  #   before = ["fortress-client.service"];
  #   serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
  #   script = ''
  #     if [ ! -s /var/lib/fortress/wg-private.key ] && [ -s /var/lib/cococoir/wg-private.key ]; then
  #       install -D -m 0600 -o root -g root \
  #         /var/lib/cococoir/wg-private.key /var/lib/fortress/wg-private.key
  #     fi
  #   '';
  # };
}
