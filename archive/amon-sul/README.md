# amon-sul — archived "all-in-one" machine config

Archived 2026-10-06 during the ADR-035 / ADR-037 migration. The
`amon-sul.nix` beside this file is the machine config exactly as it was
deployed: **one** NixOS config carrying both hardware *and* the fortress
app config (services + storage + tunnel), applied by `nixos-rebuild`.

The replacement splits that in two (ADR-037): a hardware-only machine
flake (`modules/systems/amon-sul.nix`) plus a stateful app config at
`/etc/fortress/config/` on the box, applied at run time by the applier
trampoline. This directory records what the old config *was*, so nothing
about the box is lost.

## What amon-sul ran at archive time

**Hardware / OS**
- hostname `amon-sul`; systemd-boot; stateVersion 24.11; TZ America/Denver
- `enp11s0` static `192.168.0.7/24`, gateway `192.168.0.1`, DNS
  `8.8.8.8`/`1.1.1.1` (static because DHCP never leases on this NIC)
- firewall `22 80 443 53/tcp`, `53/udp`; openssh (key-only); tailscale
- users: `nicole` (wheel), `brad`, `matthewkrumlauf`
- media pool `/dev/sda1` (UUID `5424a16e-700b-4620-b7f9-713a1619eb88`,
  LABEL `tank`): single 14.6T btrfs, `layout = "stripe"` (no
  redundancy), mounted at `/media` (`subvolid=5`). Media lives at
  `/media/entertain/{movies,shows,music}`.

**Fortress app** (the part that moves to the stateful folder)
- exposure: `baseDomain = "fractal.interdim.net"`, `tls.mode = "acme"`,
  `network.lanAddress = "192.168.0.7"`
- enabled: `jellyfin` (+ jellarr, `mediaRoot = "/media/entertain"`),
  `dex`, `media` (→ radarr + sonarr + qbittorrent + seerr),
  `fortress-client` (the tunnel)
- `public = true`: dex, jellyfin
- `public = true` **without** `enable = true`: cryptpad, forgejo — the
  silent no-op; these were never running on the box
- `public = false`: radarr, sonarr, qbittorrent, seerr
- dex OIDC users (bcrypt hashes are in the archived `amon-sul.nix`):
  `nicole@fractal.interdim.net` (admins),
  `brad@fractal.interdim.net` (users)
- jellarr libraries overridden to the on-disk layout
  (`/media/entertain/<type>`), not the module default
  (`<mediaRoot>/<type>/library`)
- tunnel: wg0 client, edge `62.238.111.21:51820`, ip `10.10.0.3/24`,
  forwards `:80`/`:443` → `127.0.0.1`; one-time copy of the legacy wg key
  `/var/lib/cococoir/wg-private.key` → `/var/lib/fortress/wg-private.key`
- `networking.hosts` loopback aliases for the four vhosts

## What moved where

| Concern | Now lives |
| --- | --- |
| boot, users, network, tailscale, ssh, firewall | machine flake `modules/systems/amon-sul.nix` |
| `/media` btrfs mount + autoScrub | machine flake (the pool already exists; the machine owns it) |
| baseDomain / tls / lanAddress, service toggles | stateful config `/etc/fortress/config/config.nix` |
| dex OIDC users, jellarr libraries, tunnel client + forwards | stateful config |
| `networking.hosts` loopback aliases | machine flake (host-OS concern; the applier cannot write `/etc/hosts`) |

## NOT carried over yet — the outage window

The applier (`nix/system-manager/fortress.nix`) supports **only dex and
caddy** today; `jellyfin`, `jellarr`, `radarr`, `sonarr`, `qbittorrent`
and `seerr` are stubs in `host-shim.nix` that hard-fail if enabled. So
after the cutover the box comes up with **dex + caddy + fortress-client +
fortress-dns**; the media stack stays dark until each service is
graduated into the applier and added back to `config.nix`. Tailscale and
SSH remain, so the box stays reachable.

## Cutover runbook (needs root on the box)

1. **Commit + push cococoir** (the applier module `nixosModules.applier`
   must exist at the rev limonene pins).
2. Update the pin: `cd ~/limonene && nix flake update cococoir`.
3. On the box: generate the magic folder — run the packaged
   `fortress-bootstrap --root /etc/fortress` (root). It creates the
   device key, git repo, `flake.nix`, a **generic** `config.nix`, and
   sealed secrets.
4. On the box: overwrite `/etc/fortress/config/config.nix` with this
   directory's `config.nix` (the real amon-sul app config), then
   `git -C /etc/fortress/config commit -am "amon-sul app config"`.
5. On the box: validate before cutting over —
   `nix build /etc/fortress/config#systemConfigs.fortress.unitsDir`
   (builds the unit tree, starts nothing).
6. On the box: `sudo nixos-rebuild switch --flake ~/limonene#amon-sul`,
   then `sudo reboot`.
7. Verify: `systemctl status fortress-apply`, dex on :5556, tunnel up,
   tailscale/ssh still reachable.
