{...}: {
  flake.modules.homeManager.firefox = {pkgs, ...}: {
    programs.firefox = {
      enable = true;
      profiles.default = {
        isDefault = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          youtube-recommended-videos
          ublock-origin
          bitwarden
          sponsorblock
          aw-watcher-web
          dearrow
          leechblock-ng
          react-devtools
          tabliss
          onetab
        ];
        settings = {
          "extensions.autoDisableScopes" = 0;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "browser.ping-centre.telemetry" = false;
        };
      };
    };
  };
}
