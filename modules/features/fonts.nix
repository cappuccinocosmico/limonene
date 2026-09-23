{...}: {
  flake.modules.homeManager.fonts = {pkgs, ...}: {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      dancing-script
      fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.monofur
      nerd-fonts.victor-mono
      nerd-fonts.monoid
      dejavu_fonts
      ubuntu-sans
      monocraft
      miracode
    ];
  };
}
