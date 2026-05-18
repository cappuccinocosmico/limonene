{inputs, ...}: {
  flake.modules.homeManager.githubNotifications = {
    pkgs,
    ...
  }: let
    github-notify = pkgs.writeShellApplication {
      name = "github-notify";
      runtimeInputs = with pkgs; [
        gh
        jq
        libnotify
        coreutils
      ];
      text = ''
        set -euo pipefail

        STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/github-notifications"
        LAST_CHECK_FILE="$STATE_DIR/last_check"
        mkdir -p "$STATE_DIR"

        now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

        if [ ! -s "$LAST_CHECK_FILE" ]; then
          echo "$now" > "$LAST_CHECK_FILE"
          exit 0
        fi

        last_check=$(cat "$LAST_CHECK_FILE")

        # Fetch unread notifications updated since the last check.
        # Silence stderr so transient network errors don't spam the journal.
        if ! notifications=$(gh api notifications --paginate -f since="$last_check" 2>/dev/null); then
          exit 0
        fi

        count=$(jq 'length' <<< "$notifications")

        if [ "$count" -eq 0 ]; then
          echo "$now" > "$LAST_CHECK_FILE"
          exit 0
        fi

        while IFS= read -r notification; do
          title=$(jq -r '.subject.title' <<< "$notification")
          repo=$(jq -r '.repository.full_name' <<< "$notification")
          type=$(jq -r '.subject.type' <<< "$notification")

          notify-send \
            --app-name="GitHub" \
            --urgency=normal \
            "GitHub: $repo" \
            "[$type] $title"
        done < <(jq -c '.[]' <<< "$notifications")

        echo "$now" > "$LAST_CHECK_FILE"
      '';
    };
  in {
    home.packages = [github-notify];

    systemd.user.services.github-notifications = {
      Unit = {
        Description = "GitHub notifications poller";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${github-notify}/bin/github-notify";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    systemd.user.timers.github-notifications = {
      Unit = {
        Description = "Poll GitHub notifications every 5 minutes";
      };
      Timer = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
        Unit = "github-notifications.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
