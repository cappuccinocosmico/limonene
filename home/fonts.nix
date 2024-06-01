
{ inputs, lib, config, pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs;[
    nerdfonts
    # (nerdfonts.override { fonts = ["3269" "FiraCode" "DroidSansMono" "Monofur" "VictorMono" "HeavyData" ]; })
    dejavu_fonts
    monocraft
    ];
}

