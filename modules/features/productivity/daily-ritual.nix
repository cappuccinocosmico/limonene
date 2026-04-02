{ inputs, ... }: {
  flake.modules.homeManager.dailyRitual = { pkgs, lib, config, ... }:
    let
      daily-ritual = pkgs.writeShellScriptBin "daily-ritual" ''
        set -euo pipefail

        GOALS_DIR="$HOME/.local/share/daily-goals"
        TODAY=$(${pkgs.coreutils}/bin/date +%Y-%m-%d)
        TODAY_FILE="$GOALS_DIR/$TODAY.json"
        YESTERDAY=$(${pkgs.coreutils}/bin/date -d "yesterday" +%Y-%m-%d)
        YESTERDAY_FILE="$GOALS_DIR/$YESTERDAY.json"

        # Gate mode: check if already done today, launch ritual if not
        if [ "''${1:-}" = "--gate" ]; then
          if [ -f "$TODAY_FILE" ]; then
            exit 0
          fi
          ${pkgs.sway}/bin/swaymsg mode ritual 2>/dev/null || true
          exec ${pkgs.kitty}/bin/kitty --class daily-ritual -e daily-ritual
        fi

        # Skip mode: create minimal file, kill ritual window, exit
        if [ "''${1:-}" = "--skip" ]; then
          mkdir -p "$GOALS_DIR"
          ${pkgs.jq}/bin/jq -cn \
            --arg date "$TODAY" \
            '{date: $date, skipped_ritual: true, negative_pomodoro_sessions: 0, goals: [], yesterday_review: ""}' \
            > "$TODAY_FILE"
          ${pkgs.sway}/bin/swaymsg '[app_id="daily-ritual"] kill' 2>/dev/null || true
          exit 0
        fi

        # === Main TUI ===
        mkdir -p "$GOALS_DIR"
        trap '${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true' EXIT

        ${pkgs.gum}/bin/gum style --border double --padding "1 2" --border-foreground 212 \
          "Daily Ritual — $TODAY"

        # Show yesterday's goals if file exists
        if [ -f "$YESTERDAY_FILE" ]; then
          echo ""
          ${pkgs.gum}/bin/gum style --foreground 212 "Yesterday's goals ($YESTERDAY):"
          ${pkgs.jq}/bin/jq -r '.goals[] | (if .done then "  ✅ " else "  ❌ " end) + .text' "$YESTERDAY_FILE" 2>/dev/null || true
          echo ""
        fi

        # Yesterday review
        ${pkgs.gum}/bin/gum style --foreground 212 "How did yesterday go? (Ctrl+D to finish)"
        review=$(${pkgs.gum}/bin/gum write --placeholder "Brief review of yesterday..." --char-limit 0 || true)

        # Today's goals
        echo ""
        ${pkgs.gum}/bin/gum style --foreground 212 "Set today's goals (empty line to finish):"
        goals_json="[]"
        while true; do
          goal=$(${pkgs.gum}/bin/gum input --placeholder "Add a goal... (empty to finish)" || true)
          if [ -z "$goal" ]; then break; fi
          goals_json=$(echo "$goals_json" | ${pkgs.jq}/bin/jq --arg text "$goal" '. += [{"text": $text, "done": false}]')
          echo "  + $goal"
        done

        ${pkgs.jq}/bin/jq -cn \
          --arg date "$TODAY" \
          --argjson goals "$goals_json" \
          --arg review "$review" \
          '{date: $date, skipped_ritual: false, negative_pomodoro_sessions: 0, goals: $goals, yesterday_review: $review}' \
          > "$TODAY_FILE"

        ${pkgs.gum}/bin/gum style --foreground 2 "Goals set for today!"
        sleep 1

        ${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true
      '';
    in
    {
      options.limonene.productivity.dailyRitual = lib.mkOption {
        type = lib.types.package;
        default = daily-ritual;
      };

      config = {
        home.packages = [ daily-ritual pkgs.gum pkgs.jq pkgs.kitty ];

        systemd.user.services.daily-ritual-resume = {
          Unit = {
            Description = "Run daily-ritual gate after system resume";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            Restart = "on-failure";
            ExecStart = "${pkgs.writeShellScript "daily-ritual-resume" ''
              exec ${pkgs.dbus}/bin/dbus-monitor --system \
                "type='signal',sender='org.freedesktop.login1',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" \
              | while IFS= read -r line; do
                case "$line" in
                  *"boolean false"*)
                    sleep 2
                    ${daily-ritual}/bin/daily-ritual --gate
                    ;;
                esac
              done
            ''}";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
}
