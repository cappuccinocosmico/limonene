{ inputs, ... }: {
  flake.modules.homeManager.easyeffects = { lib, ... }: let
    outputPreset = file: (builtins.fromJSON (builtins.readFile file)).output;
  in {
    services.easyeffects = {
      enable = true;
      preset = "Hifiman Aryas";
      extraPresets = {
        "Hifiman Aryas" = {
          output = outputPreset ./presets/hifiman-aryas.json;
        };
        "Truthear Gates" = {
          output = outputPreset ./presets/truthear-gates.json;
        };
        "No Eq" = {
          output = outputPreset ./presets/no-eq.json;
        };
      };
    };
  };
}
