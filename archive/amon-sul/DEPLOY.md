# amon-sul cutover — deploy runbook (2026-10-06)

Split per ADR-037. `README.md` describes what the old config was; this is
the exact procedure to cut the box over. It is **unverified live** — the
applier has never run on real hardware, only on `smtest`.

The applier (`nixosModules.applier`) is committed and pushed to cococoir
`main` at `a3c5fad`, and `flake.lock` now pins it, so the machine flake
builds with no override. All files here are committed to limonene `main` on
vermissian; the box needs them pulled (it has no GitHub access).

## Get the changes onto the box

The box cannot reach GitHub, so pull from vermissian. Its `limonene` has
diverged with a local commit `3dc72c2 "amon-sul config stuff"` — it carries
the new `amon-sul.nix` (identical to vermissian's) and a stray
`amon-sul.nix.prebak`, but **not** the `flake.lock` pin, so a rebuild would
fail on `nixosModules.applier`. Vermissian's `main` is canonical; reset the
box's checkout to it — the local commit is redundant:

```bash
# from the bundle the assistant copied to the box (no auth needed):
git -C /home/nicole/limonene fetch /home/nicole/limonene.bundle main
git -C /home/nicole/limonene reset --hard FETCH_HEAD

# alternative, over the tailnet (needs the box's key allowed on vermissian):
git -C /home/nicole/limonene fetch nicole@100.64.20.107:/home/nicole/limonene main
git -C /home/nicole/limonene reset --hard FETCH_HEAD
```

This drops `3dc72c2` and the `amon-sul.nix.prebak` file; the old config is
preserved as `archive/amon-sul/amon-sul.nix`. Everything below is then at
`/home/nicole/limonene/archive/amon-sul/`.

## Prerequisites (found 2026-10-06)

1. **The box has no working DNS.** `/etc/resolv.conf` is tailscale's
   MagicDNS (`100.100.100.100`), which does not resolve public names here:
   `getent hosts github.com` fails, `curl https://cache.nixos.org` fails.
   Every Nix fetch breaks, so the applier's boot-time build cannot work.
   Live fix is step 1 below; the durable fix
   (`services.tailscale.extraSetFlags = [ "--accept-dns=false" ]`) is in the
   new machine flake.
2. **No passwordless sudo** — the root steps below must be run by a human.

## Part A — already in the repo (`archive/amon-sul/`)

- `amon-sul.nix` — the old all-in-one config (archive).
- `README.md` — what the box ran.
- `config.nix` — the app-config target (each block marked applier-ready /
  blocked).
- `flake.nix` — the magic-folder flake, pinning cococoir `a3c5fad`.
- `fortress-bootstrap.sh` — the folder generator (the box's own cococoir
  checkout is stale and lacks it).
- The new hardware-only machine flake is `modules/systems/amon-sul.nix`.

## Part B — root, on the box

```bash
A=/home/nicole/limonene/archive/amon-sul

# 1. unblock DNS for the duration (MagicDNS does not resolve public names)
sudo tailscale set --accept-dns=false || true
printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' | sudo tee /etc/resolv.conf >/dev/null
getent hosts github.com            # MUST print an address before continuing

# 2. generate the magic folder (device age key + git repo + sealed secrets)
sudo bash $A/fortress-bootstrap.sh --root /etc/fortress

# 3. drop in amon-sul's real app config + the pinned flake, and re-lock
sudo cp $A/flake.nix  /etc/fortress/config/flake.nix
sudo cp $A/config.nix /etc/fortress/config/config.nix
sudo rm -f /etc/fortress/config/flake.lock
sudo git -C /etc/fortress/config -c user.email=fortress@localhost -c user.name=fortress \
  commit -qam "amon-sul app config"

# 4. VALIDATE the folder builds through the applier — starts nothing.
#    If this fails, STOP; nothing has been cut over.
sudo nix build /etc/fortress/config#systemConfigs.fortress.unitsDir

# 5. cut over, then reboot (the applier re-applies on boot; /run is tmpfs)
sudo nixos-rebuild switch --flake /home/nicole/limonene#amon-sul
sudo reboot
```

## Part C — verify after reboot

```bash
systemctl status fortress-apply.service fortress-bootstrap.service
systemctl status dex.service fortress-dns.service caddy.service   # caddy only if a service is public
curl -sf http://127.0.0.1:5556/dex/.well-known/openid-configuration | head -c 120
getent hosts github.com            # DNS must still work (machine flake's extraSetFlags)
tailscale status | head -2         # still on the tailnet
```

Expected end state: **dex on loopback only** — no public vhosts, no ACME,
no tunnel, no media stack. That is the accepted window until services are
graduated into the applier and re-added to `/etc/fortress/config/config.nix`.

## Rollback

`nixos-rebuild switch` is atomic and `systemd-boot` keeps prior
generations. If the new generation misbehaves:

```bash
sudo nixos-rebuild switch --rollback && sudo reboot
```

The media pool is never touched — the cutover only *mounts* `/dev/sda1`
(UUID `5424a16e-700b-4620-b7f9-713a1619eb88`); no `mkfs`, and the app config
uses `plain-dirs`.

## Known-unverified (expect to iterate)

- The applier has never run on real hardware; `smtest` shares the host
  store, so a first build-from-scratch on amon-sul is new territory.
- `services.tailscale.extraSetFlags` (the durable DNS fix) runs
  `tailscale set` at boot; if it races tailscaled the box reverts to broken
  DNS on reboot. The tailnet-console fix (add a global nameserver) is the
  more robust alternative.
- Bootstrap's `nix flake lock` needs GitHub reachable; if DNS regresses
  mid-run, step 4 fails cleanly and nothing is cut over.
