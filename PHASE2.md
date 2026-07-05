# Phase 2: Add opencode secrets for brad

This document describes the steps to finish the brad multi-user setup after
Phase 1 has been built and activated. Phase 1 installs `sops` (via
`cliTools`) so that you can create the encrypted secrets file.

## Current status

On branch `add-brad-to-cheddar`, the following are already done:

- `modules/features/opencode-brad.nix` exists and defines `OPENCODE_ZEN_API_KEY`
  plus `~/.config/opencode/opencode.json` with the `go` provider (trial-and-error).
- `modules/users/brad-darwin.nix` imports `opencode-brad`.
- `secrets/brad-secrets.yaml` exists and is encrypted, but contains the
  placeholder value `REPLACE_ME`.

The remaining work is:

1. Replace `REPLACE_ME` with the real `OPENCODE_ZEN_API_KEY`.
2. Run `darwin-rebuild switch --flake ~/limonene#cheddar`.
3. Test `opencode go`.
4. If `go` is not the correct provider name, edit the provider key in
   `modules/features/opencode-brad.nix` and rebuild.

## Key model

The repo uses a **one-key-per-user** model. `.sops.yaml` encrypts all
`secrets/*.yaml` files for both nicole's and brad's age public keys. Each user
keeps their private key on their own machines; no private keys need to be moved
between machines. If you later want per-machine keys, update `.sops.yaml` with
machine-specific recipients.

## Prerequisites

Phase 1 must already be active on `cheddar`:

- brad’s user account exists with UID 502.
- `sops` is installed and on PATH (run `which sops` to verify).
- brad has an age key at `~brad/.config/sops/age/keys.txt`.
  If not, generate one as brad:
  ```bash
  mkdir -p ~/.config/sops/age
  age-keygen -o ~/.config/sops/age/keys.txt
  ```
  Note the public key printed to stdout; you will add it to `.sops.yaml` if
  it is not already listed there.

The existing `.sops.yaml` already contains both nicole’s and brad’s age
public keys, so `sops secrets/brad-secrets.yaml` will encrypt for both.

## Step 1: Create and encrypt `secrets/brad-secrets.yaml`

Create the plaintext secrets file. Replace the example keys below with the
actual secrets you want opencode to load. Since you are not using OpenRouter,
do **not** include `OPENROUTER_API_KEY`. Add whichever provider keys you use
instead, for example:

```yaml
OPENCODE_ZEN_API_KEY: your_opencode_zen_key_here
ANTHROPIC_API_KEY: your_anthropic_key_here
OPENAI_API_KEY: your_openai_key_here
```

Save it as `secrets/brad-secrets.yaml`, then encrypt it:

```bash
sops secrets/brad-secrets.yaml
```

`sops` will open the file in your editor. Save and quit; the file is now
encrypted for the age recipients listed in `.sops.yaml`.

## Step 2: Create `modules/features/opencode-brad.nix` (already done)

The file already exists on `add-brad-to-cheddar`. Reference content:

Adjust `secretEnvVars` to match exactly the keys you put in
`secrets/brad-secrets.yaml`:

```nix
{inputs, ...}: {
  flake.modules.homeManager.opencode-brad = {
    config,
    lib,
    ...
  }: let
    secretEnvVars = [
      "OPENCODE_ZEN_API_KEY"
      # Add other provider keys here, e.g.:
      # "ANTHROPIC_API_KEY"
      # "OPENAI_API_KEY"
    ];

    mkFishInit = varName: ''
      if test -f "${config.sops.secrets.${varName}.path}"
        set -gx ${varName} (cat "${config.sops.secrets.${varName}.path}")
      end
    '';
  in {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    sops.secrets = lib.genAttrs secretEnvVars (_: {
      sopsFile = ../../secrets/brad-secrets.yaml;
    });

    programs.fish.interactiveShellInit = lib.concatStringsSep "\n" (map mkFishInit secretEnvVars);

    home.sessionPath = [
      "$HOME/.opencode/bin"
    ];
  };
}
```

## Step 3: Import `opencode-brad` in brad’s darwin user module (already done)

`modules/users/brad-darwin.nix` already imports `opencode-brad`:

```nix
home-manager.users.brad = {config, ...}: {
  imports = [
    inputs.self.modules.homeManager.userCommon
    inputs.self.modules.homeManager.brad-darwin-desktop
    inputs.self.modules.homeManager.opencode-brad
  ];
  # ... rest of config unchanged
};
```

## Step 4: `~/.config/opencode/opencode.json` (already done)

The module generates this file with the `go` provider as a trial:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "go": {
      "options": {
        "apiKey": "{env:OPENCODE_ZEN_API_KEY}"
      }
    }
  }
}
```

If `go` is not the correct provider name, change `"go"` in
`modules/features/opencode-brad.nix` and rebuild.

## Step 5: Validate and rebuild

Run a dry-run build first:

```bash
nix build --dry-run ~/limonene#darwinConfigurations.cheddar.config.system.build.toplevel
```

If that succeeds, activate:

```bash
darwin-rebuild switch --flake ~/limonene#cheddar
```

Activation must be run locally in a graphical session (not over SSH) because
home-manager changes for a user may require full disk access.

## Step 6: Verify opencode works

Open a new fish shell as brad and check:

```bash
echo $OPENCODE_ZEN_API_KEY
cat ~/.config/opencode/opencode.json
which opencode
opencode go
```

If the environment variable is empty, check the sops-nix logs in the
home-manager activation output and ensure `~brad/.config/sops/age/keys.txt`
exists and is readable.

## Troubleshooting

- **sops complains about missing `.sops.yaml` creation rule**: ensure
  `.sops.yaml` lists brad’s age public key under the `secrets/.*\.yaml$`
  rule.
- **`darwin-rebuild` fails because `secrets/brad-secrets.yaml` is
  unencrypted**: run `sops secrets/brad-secrets.yaml` and rebuild.
- **A secret key is missing at runtime**: the `secretEnvVars` list in
  `opencode-brad.nix` must exactly match the keys in `brad-secrets.yaml`.
- **opencode binary is missing**: this setup only configures secrets and PATH.
  Install opencode itself to `~brad/.opencode/bin` separately (e.g.
  `opencode install` or by copying the binary).
