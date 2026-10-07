# amon-sul cutover — deploy runbook

Split per ADR-037. `README.md` describes what the old config was. The
applier is proven on `smtest` (2026-10-07 — Caddy active, Dex proxied on the
LAN plane, survives re-apply + reboot) but not yet on real hardware.

> **Pin invariant.** The machine flake (`limonene/flake.lock`) and the
> folder seed (`archive/amon-sul/flake.nix`) pin cococoir *independently*
> and MUST name the same rev. Commit `2f5436d` bumped only the machine one,
> so the applier kept building the old `a3c5fad` and died on
> `caddy.service: status=217/USER`. Both now pin `6fcf25b` (Caddy under the
> applier).

## Already cut over? Re-apply the app layer

The OS is already switched, so only the app layer (the magic folder) needs
the new pin. The folder is a **git repo**, and nix builds it from the
committed tree — an uncommitted edit is invisible, so the change must be
committed:

```bash
sudo sed -i \
  's|/a3c5fad179d219eee48c30b992a99772b7605e2f|/6fcf25bb64c1ae7b44b151262eb9b18cc0e319d6|' \
  /etc/fortress/config/flake.nix
sudo rm -f /etc/fortress/config/flake.lock
sudo git -C /etc/fortress/config -c user.email=fortress@localhost -c user.name=fortress \
  commit -qam "re-pin cococoir to 6fcf25b (caddy under the applier)"
sudo fortress-apply            # rebuilds + restarts fortress.target; no nixos-rebuild
```

`6fcf25b` is already in the box's store (the machine flake fetched it), so
this needs no network. Verify with Part C. (`sudo nixos-rebuild switch
--flake .` in `~/limonene` also re-runs `fortress-apply` on boot — but it
re-applies the *same* folder, so fixing the folder is what matters.)

## Prerequisites (found 2026-10-06)

1. **The box's DNS was broken.** `/etc/resolv.conf` was tailscale's MagicDNS
   (`100.100.100.100`), which does not resolve public names:
   `getent hosts github.com` failed. The durable fix
   (`services.tailscale.extraSetFlags = [ "--accept-dns=false" ]`) is in the
   machine flake; the live fix is step 1 of Part B.
2. **No passwordless sudo** — the root steps must be run by a human.

## Part A — repo layout (`archive/amon-sul/`)

- `amon-sul.nix` — the old all-in-one config (archive).
- `README.md` — what the box ran.
- `config.nix` — the app-config target (each block marked applier-ready /
  blocked).
- `flake.nix` — the magic-folder flake, pinning cococoir `6fcf25b`.
- `fortress-bootstrap.sh` — the folder generator.
- The hardware-only machine flake is `limonene/modules/systems/amon-sul.nix`.

## Part B — first-time cutover (already done on amon-sul)

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

## Part C — verify

```bash
systemctl status fortress-apply.service caddy.service dex.service fortress-dns.service
curl -sf http://127.0.0.1:5556/dex/.well-known/openid-configuration | head -c 120   # dex direct
curl -sf http://192.168.0.7/dex/.well-known/openid-configuration | head -c 120     # through Caddy (LAN plane)
getent hosts github.com            # DNS must still work (machine flake's extraSetFlags)
tailscale status | head -2         # still on the tailnet
```

Expected end state: **Dex fronted by Caddy on the LAN plane** (`192.168.0.7`),
no ACME (Caddy's auto-HTTPS on the clearnet hostname has no network yet), no
tunnel, no media stack. That is the accepted window until the remaining
services are graduated into the applier and re-added to
`/etc/fortress/config/config.nix`.

## Rollback

`nixos-rebuild switch` is atomic and `systemd-boot` keeps prior generations:

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
- With `fortress.tls.mode = "off"`, Caddy still auto-promotes the clearnet
  hostname to HTTPS (ACME) and will fail without network; the LAN plane
  (`http://<lan>/dex`) is the plain-HTTP path the e2e uses.
