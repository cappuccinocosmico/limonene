{ inputs, lib, config, pkgs, system, ... }: {
  imports = [
    # inputs.zen-browser.homeModules.beta
    # inputs.zen-browser.homeModules.beta
    # or inputs.zen-browser.homeModules.twilight
    # or inputs.zen-browser.homeModules.twilight-official
  ];

  # programs.zen-browser = {
  #   # mozilla= true;
  #   enable = true;
  #   nativeMessagingHosts = [pkgs.firefoxpwa];
  # };
  # mozilla = true;
  home.packages = [
    # inputs.zen-browser.packages."${system}".beta
    inputs.zen-browser.packages."x86_64-linux".beta
    # inputs.zen-browser.packages
    # inputs.zen-browser.packages."x86-64-linux".beta
  ];
}
