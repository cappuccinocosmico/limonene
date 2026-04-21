{inputs, ...}: {
  flake.modules.homeManager.opencode = {config, ...}: {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    sops.secrets.openrouter_api_key = {
      sopsFile = ../../secrets/nicole-secrets.yaml;
    };

    # Render auth.json with the decrypted key substituted in by sops-nix.
    # opencode reads provider credentials from this file, not from config.json.
    sops.templates."opencode-auth" = {
      content = ''{"openrouter":{"type":"api","key":"${config.sops.placeholder.openrouter_api_key}"}}'';
      path = "${config.home.homeDirectory}/.local/share/opencode/auth.json";
      mode = "0600";
    };

    # Since new OSS models are coming out so frequently I am going to switch over to a regular install for this.
    home.sessionPath = [
      "$HOME/.opencode/bin"
    ];
    programs.opencode = {
      enable = false;
      settings = {
        autoupdate = false;
        autoshare = false;
        provider.openrouter.models = {
          "nvidia/nemotron-3-nano-30b-a3b" = {};
        };
      };
    };
  };
}
