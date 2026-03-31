{...}: {
  flake.modules.homeManager.firefox = {pkgs, ...}: {
    programs.firefox = {
      enable = true;
      profiles.default = {
        isDefault = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          # Adblockers/Enhancers
          ublock-origin
          sponsorblock
          bitwarden
          return-youtube-dislikes
          # Misc Productivity
          aw-watcher-web
          clearurls
          react-devtools
          onetab
          # Anti-Addiction Tools
          youtube-recommended-videos
          dearrow
          leechblock-ng
          # monochromate
          tabliss
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
