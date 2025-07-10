{ inputs, lib, config, pkgs, zen-browser, ... }: {
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
}
