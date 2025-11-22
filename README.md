# Limonene

NixOS and macOS system configuration flake.

## Structure

```
home/
  common.nix          # Cross-platform config (shells, nvim, git, cli tools)
  common/             # Shared modules
  linux/              # Linux-specific packages
  nicole.nix          # Linux home-manager config
  nicole-darwin.nix   # macOS home-manager config

system/               # NixOS system configurations
flake.nix             # Flake definition
```

## macOS Setup

### Prerequisites

1. Install Nix using the Determinate Systems installer:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Restart your terminal or run:
   ```bash
   . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   ```

### Configuration

1. Clone this repo:
   ```bash
   git clone <repo-url> ~/limonene
   cd ~/limonene
   ```

2. Get your Mac's hostname:
   ```bash
   scutil --get LocalHostName
   ```

3. Update `flake.nix` - replace `"nicole-mac"` with your hostname in the `darwinConfigurations` section (around line 93).

4. If you have an Intel Mac, change `aarch64-darwin` to `x86_64-darwin` on line 94.

### Initial Install

Run nix-darwin for the first time:
```bash
nix run nix-darwin -- switch --flake .#<your-hostname>
```

This will:
- Install nix-darwin
- Set up home-manager
- Install all packages (neovim, fish, git, nodejs, go, etc.)

### Rebuilding

After making changes to the configuration:
```bash
darwin-rebuild switch --flake ~/limonene#<your-hostname>
```

### What's Included (macOS)

- **Shell**: fish, zellij, tmux, direnv
- **Editor**: neovim (via nvf) with LSP, treesitter, telescope
- **CLI tools**: ripgrep, fd, bat, eza, lazygit, gh, jq, etc.
- **Languages**: nodejs (with corepack/pnpm), go, python (uv, pyright), zig, lua
- **Git**: configured with your name/email

### Enabling pnpm

pnpm is provided via corepack. Enable it with:
```bash
corepack enable pnpm
```

## NixOS Setup

### Rebuilding

```bash
sudo nixos-rebuild switch --flake ~/limonene#<hostname>
```

Available configurations:
- `incarnadine` - Framework laptop
- `vermissian` - Server

## Notes

### Fedora Autologin

On Fedora to get autologin, run:

```bash
sudo systemctl edit getty@tty1.service
```

Add to the file:

```bash
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin username %I $TERM
```
