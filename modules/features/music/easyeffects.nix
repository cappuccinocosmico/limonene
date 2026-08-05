{ inputs, ... }: {
  flake.modules.homeManager.easyeffects = { lib, ... }: {
    services.easyeffects = {
      enable = true;
      preset = "Hifiman Aryas";
      extraPresets = {
        "Hifiman Aryas" = {
          output = builtins.fromJSON (builtins.readFile ./presets/hifiman-aryas.json);
        };
        "Truthear Gates" = {
          output = builtins.fromJSON (builtins.readFile ./presets/truthear-gates.json);
        };
        "No Eq" = {
          output = builtins.fromJSON (builtins.readFile ./presets/no-eq.json);
        };
      };
    };
  };
}
