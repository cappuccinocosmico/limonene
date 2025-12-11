# Limonene


TO INSTALL ON MACOS CLONE THE REPO CD INTO IT AND RUN:

sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin/master#darwin-rebuild -- switch --flake .#cheddar


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

### Window Management (yabai + skhd)

The configuration files for yabai and skhd are managed by nix, but the binaries must be installed separately via Homebrew for better permission handling.

#### Installation

```bash
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
```

#### Start Services

```bash
yabai --start-service
skhd --start-service
```

#### Permissions

Both tools require Accessibility permissions:
1. Open System Settings > Privacy & Security > Accessibility
2. Add and enable `/opt/homebrew/bin/yabai`
3. Add and enable `/opt/homebrew/bin/skhd`

#### Optional: Full yabai Functionality

For features like moving windows across spaces, yabai requires SIP to be partially disabled:

1. Boot into Recovery Mode (hold power button on Apple Silicon, or Cmd+R on Intel)
2. Open Terminal from Utilities menu
3. Run:
   ```bash
   csrutil enable --without fs --without debug --without nvram
   ```
4. Reboot and run:
   ```bash
   sudo yabai --load-sa
   ```

To load the scripting addition on startup, uncomment the relevant lines in the yabairc.

#### Key Bindings

The skhd configuration uses `alt` (option) as the modifier to avoid conflicts with macOS defaults:

- **Focus**: `alt + h/j/k/l`
- **Swap**: `alt + shift + h/j/k/l`
- **Space**: `alt + 1-9,0`
- **Move to space**: `alt + shift + 1-9,0`
- **Close window**: `alt + q`
- **Terminal**: `alt + return`
- **Fullscreen**: `alt + f`
- **Float toggle**: `alt + shift + space`
- **Restart yabai**: `alt + shift + r`

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
