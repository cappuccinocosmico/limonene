{ inputs, ... }: {
  flake.modules.homeManager.productivityDaemon = { pkgs, lib, config, ... }:
    let
      productivityTs = ./. + "/_productivity.ts";

      # Wrap the TypeScript source so bun can find it at a known store path
      productivity-bin = pkgs.writeShellScriptBin "productivity" ''
        exec ${pkgs.bun}/bin/bun run ${productivityTs} "$@"
      '';

      productivity-daemon-bin = pkgs.writeShellScriptBin "productivity-daemon" ''
        exec ${pkgs.bun}/bin/bun run ${productivityTs} --daemon "$@"
      '';

      # Gum-based panel TUI — same as before but calls productivity CLI
      pomodoro-panel = pkgs.writeShellScriptBin "pomodoro-panel" ''
        set -euo pipefail

        format_time() {
          local ms="$1"
          local secs=$(( ms / 1000 ))
          printf "%d:%02d" $(( secs / 60 )) $(( secs % 60 ))
        }

        is_running() {
          local status
          status=$(${productivity-bin}/bin/productivity pomodoro status 2>/dev/null) || return 1
          echo "$status" | ${pkgs.jq}/bin/jq -e '.running == true' > /dev/null 2>&1
        }

        if ! is_running; then
          choice=$(${pkgs.gum}/bin/gum choose \
            "10/10 (10min nothing, 10min work)" \
            "10/20 (10min nothing, 20min work)" \
            "20/20 (20min nothing, 20min work)" \
            "Custom" || true)

          case "$choice" in
            "10/10"*) ${productivity-bin}/bin/productivity pomodoro start 10 10 ;;
            "10/20"*) ${productivity-bin}/bin/productivity pomodoro start 10 20 ;;
            "20/20"*) ${productivity-bin}/bin/productivity pomodoro start 20 20 ;;
            "Custom")
              neg=$(${pkgs.gum}/bin/gum input --placeholder "Nothing minutes" --value "10" || true)
              work=$(${pkgs.gum}/bin/gum input --placeholder "Work minutes" --value "20" || true)
              if [ -n "$neg" ] && [ -n "$work" ]; then
                ${productivity-bin}/bin/productivity pomodoro start "$neg" "$work"
              else
                exit 0
              fi
              ;;
            *) exit 0 ;;
          esac
          # Fall through to countdown after starting
        fi

        # Enter sway jail when opening the countdown (whether we just started or re-opened)
        ${pkgs.sway}/bin/swaymsg 'mode negative'

        # Timer is running — live countdown
        prev_phase=""
        while is_running; do
          status=$(${productivity-bin}/bin/productivity pomodoro status 2>/dev/null) || break
          remaining_ms=$(echo "$status" | ${pkgs.jq}/bin/jq -r '.remainingMs')
          phase=$(echo "$status" | ${pkgs.jq}/bin/jq -r '.phase')
          neg_mins=$(echo "$status" | ${pkgs.jq}/bin/jq -r '.negativeMins')
          work_mins=$(echo "$status" | ${pkgs.jq}/bin/jq -r '.workMins')

          # Switch sway mode on phase transitions
          if [ "$phase" != "$prev_phase" ] && [ -n "$prev_phase" ]; then
            if [ "$phase" = "negative" ]; then
              ${pkgs.sway}/bin/swaymsg 'mode negative'
            else
              ${pkgs.sway}/bin/swaymsg 'mode default'
            fi
          fi
          prev_phase="$phase"

          time_str=$(format_time "$remaining_ms")
          phase_upper=$(echo "$phase" | tr '[:lower:]' '[:upper:]')

          printf "\033[2J\033[H"
          ${pkgs.gum}/bin/gum style --border rounded --padding "0 1" --border-foreground 212 \
            "Negative Pomodoro" \
            "s: skip  c: cancel  +/-: adjust ±5min  q: quit panel"
          echo ""
          echo "  Phase: $phase_upper"
          echo "  Remaining: $time_str"
          echo "  Cycle: ''${neg_mins}min / ''${work_mins}min"

          if read -t 1 -n 1 key 2>/dev/null; then
            case "$key" in
              s) ${productivity-bin}/bin/productivity pomodoro skip ;;
              c) ${productivity-bin}/bin/productivity pomodoro cancel
                 ${pkgs.sway}/bin/swaymsg 'mode default'
                 exit 0 ;;
              +) ${productivity-bin}/bin/productivity pomodoro adjust 5 ;;
              -) ${productivity-bin}/bin/productivity pomodoro adjust -- -5 ;;
              q) exit 0 ;;  # close panel, timer and sway mode stay active
            esac
          fi
        done

        # Timer ended naturally
        ${pkgs.sway}/bin/swaymsg 'mode default'
        echo "Timer ended."
        sleep 1
      '';

      # Gum-based popup for adding a goal
      goals-add-popup = pkgs.writeShellScriptBin "goals-add-popup" ''
        goal=$(${pkgs.gum}/bin/gum input --placeholder "New goal...")
        if [ -n "$goal" ]; then
          ${productivity-bin}/bin/productivity goals add "$goal"
        fi
      '';

      # Fuzzel-based goal toggle picker
      goals-toggle-picker = pkgs.writeShellScriptBin "goals-toggle-picker" ''
        set -euo pipefail
        status=$(${productivity-bin}/bin/productivity goals status 2>/dev/null) || exit 1
        menu=$(echo "$status" | ${pkgs.jq}/bin/jq -r '.goals[] | (if .done then "✅ " else "⬜ " end) + .text')
        if [ -z "$menu" ]; then
          ${pkgs.libnotify}/bin/notify-send "No goals" "No goals to toggle"
          exit 0
        fi
        selected=$(echo "$menu" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Toggle goal: " || true)
        if [ -z "$selected" ]; then exit 0; fi
        # Strip checkbox prefix
        selected_text=$(echo "$selected" | ${pkgs.gnused}/bin/sed 's/^[✅⬜] //')
        ${productivity-bin}/bin/productivity goals toggle "$selected_text"
      '';
    in
    {
      options.limonene.productivity = {
        productivityBin = lib.mkOption { type = lib.types.package; default = productivity-bin; };
        pomodoroPanel = lib.mkOption { type = lib.types.package; default = pomodoro-panel; };
        goalsTogglePicker = lib.mkOption { type = lib.types.package; default = goals-toggle-picker; };
        goalsAddPopup = lib.mkOption { type = lib.types.package; default = goals-add-popup; };
      };

      config = {
        home.packages = [
          productivity-bin
          productivity-daemon-bin
          pomodoro-panel
          goals-add-popup
          goals-toggle-picker
          pkgs.bun
          pkgs.gum
          pkgs.jq
          pkgs.libnotify
          pkgs.fuzzel
          pkgs.gnused
        ];

        systemd.user.services.productivity-daemon = {
          Unit = {
            Description = "Productivity daemon (pomodoro + goals)";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${productivity-daemon-bin}/bin/productivity-daemon";
            Restart = "on-failure";
            RestartSec = "2s";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
}
