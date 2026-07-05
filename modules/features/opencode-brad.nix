{inputs, ...}: {
  flake.modules.homeManager.opencode-brad = {
    config,
    lib,
    ...
  }: let
    # Add new secret env var names here; everything else is generated automatically.
    secretEnvVars = [
      "OPENCODE_ZEN_API_KEY"
    ];

    # Helper to build the fish init snippet for a single secret.
    mkFishInit = varName: ''
      if test -f "${config.sops.secrets.${varName}.path}"
        set -gx ${varName} (cat "${config.sops.secrets.${varName}.path}")
      end
    '';
  in {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Generates the sops.secrets attrset from the list of names.
    sops.secrets = lib.genAttrs secretEnvVars (_: {
      sopsFile = ../../secrets/brad-secrets.yaml;
    });

    # Generates the fish shell exports for all listed secrets.
    programs.fish.interactiveShellInit = lib.concatStringsSep "\n" (map mkFishInit secretEnvVars);

    # Since new OSS models are coming out so frequently I am going to switch over to a regular install for this.
    home.sessionPath = [
      "$HOME/.opencode/bin"
    ];
  };
}
