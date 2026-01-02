{
  inputs,
  lib,
  config,
  pkgs,
  system,
  ...
}: {
  services.kdeconnect.enable = true;

  # programs.zen-browser = {
  #   # mozilla= true;
  #   enable = true;
  #   nativeMessagingHosts = [pkgs.firefoxpwa];
  # };
  # mozilla = true;
  # home.packages = [
  # inputs.zen-browser.packages."${system}".beta
  # inputs.zen-browser.packages
  # inputs.zen-browser.packages."x86-64-linux".beta
  # ];
}
