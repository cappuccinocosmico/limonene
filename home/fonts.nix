
{ inputs, lib, config, pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs;[
    nerdfonts.FiraCode
    nerdfonts.DroidSansMono
    nerdfonts.Monofur
    nerdfonts.VictorMono
    # (nerdfonts.override { fonts = ["3269" "FiraCode" "DroidSansMono" "Monofur" "VictorMono" "HeavyData" ]; })
    dejavu_fonts
    monocraft
    ];
}

