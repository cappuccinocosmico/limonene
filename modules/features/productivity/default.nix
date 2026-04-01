{ inputs, ... }: {
  flake.modules.homeManager.productivity = { pkgs, lib, config, ... }:
    let
      daily-ritual = pkgs.writeShellScriptBin "daily-ritual" ''
        set -uo pipefail

        GOALS_DIR="$HOME/.local/share/daily-goals"
        TODAY=$(date +%Y-%m-%d)
        TODAY_FILE="$GOALS_DIR/$TODAY.md"
        YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
        YESTERDAY_FILE="$GOALS_DIR/$YESTERDAY.md"

        get_frontmatter() {
          ${pkgs.gawk}/bin/awk 'BEGIN{c=0} /^---$/{c++; next} c==1{print}' "$1"
        }

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
          cat > "$TODAY_FILE" << SKIPEOF
---
date: "$TODAY"
skipped_ritual: true
negative_pomodoro_sessions: 0
goals: []
yesterday_review: ""
---

# Notes
SKIPEOF
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
          fm=$(get_frontmatter "$YESTERDAY_FILE")
          echo "$fm" | ${pkgs.yq-go}/bin/yq -r '.goals[] | (if .done then "  ✅ " else "  ❌ " end) + .text' 2>/dev/null || true
          echo ""
        fi

        # Yesterday review
        ${pkgs.gum}/bin/gum style --foreground 212 "How did yesterday go? (Ctrl+D to finish)"
        review=$(${pkgs.gum}/bin/gum write --placeholder "Brief review of yesterday..." --char-limit 0 || true)

        # Today's goals
        echo ""
        ${pkgs.gum}/bin/gum style --foreground 212 "Set today's goals (empty line to finish):"
        goals=()
        while true; do
          goal=$(${pkgs.gum}/bin/gum input --placeholder "Add a goal... (empty to finish)" || true)
          if [ -z "$goal" ]; then
            break
          fi
          goals+=("$goal")
          echo "  + $goal"
        done

        # Build YAML goals block
        goals_yaml="goals:"
        if [ "''${#goals[@]}" -eq 0 ]; then
          goals_yaml="goals: []"
        else
          for g in "''${goals[@]}"; do
            escaped=$(printf '%s' "$g" | ${pkgs.gnused}/bin/sed 's/"/\\"/g')
            goals_yaml="$goals_yaml
  - text: \"$escaped\"
    done: false"
          done
        fi

        # Build YAML review block
        if [ -n "$review" ]; then
          review_yaml="yesterday_review: |"
          while IFS= read -r line; do
            review_yaml="$review_yaml
  $line"
          done <<< "$review"
        else
          review_yaml='yesterday_review: ""'
        fi

        cat > "$TODAY_FILE" << GOALEOF
---
date: "$TODAY"
skipped_ritual: false
negative_pomodoro_sessions: 0
$goals_yaml
$review_yaml
---

# Notes
GOALEOF

        ${pkgs.gum}/bin/gum style --foreground 2 "Goals set for today!"
        sleep 1

        ${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true
      '';

      daily-goals = pkgs.writeShellScriptBin "daily-goals" ''
        set -uo pipefail

        GOALS_DIR="$HOME/.local/share/daily-goals"
        TODAY=$(date +%Y-%m-%d)
        TODAY_FILE="$GOALS_DIR/$TODAY.md"

        get_frontmatter() {
          ${pkgs.gawk}/bin/awk 'BEGIN{c=0} /^---$/{c++; next} c==1{print}' "$1"
        }

        get_body() {
          ${pkgs.gawk}/bin/awk 'BEGIN{c=0} /^---$/{c++; next} c>=2{print}' "$1"
        }

        write_back() {
          local fm="$1" body="$2" file="$3"
          {
            echo "---"
            echo "$fm"
            echo "---"
            echo "$body"
          } > "$file"
        }

        case "''${1:-}" in
          list)
            if [ ! -f "$TODAY_FILE" ]; then
              echo "No goals set for today. Run daily-ritual first."
              exit 1
            fi
            fm=$(get_frontmatter "$TODAY_FILE")
            echo "$fm" | ${pkgs.yq-go}/bin/yq -r '.goals[] | (if .done then "✅ " else "⬜ " end) + .text'
            ;;

          toggle)
            if [ ! -f "$TODAY_FILE" ]; then
              ${pkgs.libnotify}/bin/notify-send "No goals" "No goals set for today"
              exit 1
            fi
            fm=$(get_frontmatter "$TODAY_FILE")
            body=$(get_body "$TODAY_FILE")

            # Build fuzzel menu
            menu=""
            while IFS= read -r line; do
              done_str=$(echo "$line" | ${pkgs.yq-go}/bin/yq -r '.done')
              text=$(echo "$line" | ${pkgs.yq-go}/bin/yq -r '.text')
              if [ "$done_str" = "true" ]; then
                menu="''${menu}✅ $text\n"
              else
                menu="''${menu}⬜ $text\n"
              fi
            done < <(echo "$fm" | ${pkgs.yq-go}/bin/yq -r '.goals[] | @json')

            if [ -z "$menu" ]; then
              ${pkgs.libnotify}/bin/notify-send "No goals" "No goals to toggle"
              exit 0
            fi

            selected=$(printf "$menu" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Toggle goal: " || true)
            if [ -z "$selected" ]; then
              exit 0
            fi

            # Strip emoji prefix to get goal text
            selected_text=$(echo "$selected" | ${pkgs.gnused}/bin/sed 's/^[✅⬜] //')

            # Toggle in yaml
            fm=$(echo "$fm" | ${pkgs.yq-go}/bin/yq "(.goals[] | select(.text == \"$selected_text\")).done |= not")

            write_back "$fm" "$body" "$TODAY_FILE"
            ;;

          add)
            shift
            text="$*"
            if [ -z "$text" ]; then
              exit 1
            fi

            mkdir -p "$GOALS_DIR"

            if [ ! -f "$TODAY_FILE" ]; then
              cat > "$TODAY_FILE" << ADDEOF
---
date: "$TODAY"
skipped_ritual: false
negative_pomodoro_sessions: 0
goals: []
yesterday_review: ""
---

# Notes
ADDEOF
            fi

            fm=$(get_frontmatter "$TODAY_FILE")
            body=$(get_body "$TODAY_FILE")

            escaped=$(printf '%s' "$text" | ${pkgs.gnused}/bin/sed 's/"/\\"/g')
            fm=$(echo "$fm" | ${pkgs.yq-go}/bin/yq ".goals += [{\"text\": \"$escaped\", \"done\": false}]")

            write_back "$fm" "$body" "$TODAY_FILE"
            ;;

          waybar)
            if [ ! -f "$TODAY_FILE" ]; then
              ${pkgs.jq}/bin/jq -n '{text: "no goals", tooltip: "No goals set", class: "none"}'
              exit 0
            fi

            fm=$(get_frontmatter "$TODAY_FILE")
            total=$(echo "$fm" | ${pkgs.yq-go}/bin/yq '.goals | length')
            done=$(echo "$fm" | ${pkgs.yq-go}/bin/yq '[.goals[] | select(.done == true)] | length')

            tooltip=""
            while IFS= read -r line; do
              done_str=$(echo "$line" | ${pkgs.yq-go}/bin/yq -r '.done')
              text=$(echo "$line" | ${pkgs.yq-go}/bin/yq -r '.text')
              if [ "$done_str" = "true" ]; then
                tooltip="''${tooltip}✅ $text\n"
              else
                tooltip="''${tooltip}⬜ $text\n"
              fi
            done < <(echo "$fm" | ${pkgs.yq-go}/bin/yq -r '.goals[] | @json')

            class="active"
            if [ "$total" -eq 0 ]; then
              class="none"
            elif [ "$done" -eq "$total" ]; then
              class="done"
            fi

            ${pkgs.jq}/bin/jq -n \
              --arg text "[$done/$total]" \
              --arg tooltip "$tooltip" \
              --arg class "$class" \
              '{text: $text, tooltip: $tooltip, class: $class}'
            ;;

          *)
            echo "Usage: daily-goals {list|toggle|add|waybar}"
            exit 1
            ;;
        esac
      '';

      daily-goals-add-popup = pkgs.writeShellScriptBin "daily-goals-add-popup" ''
        goal=$(${pkgs.gum}/bin/gum input --placeholder "New goal...")
        if [ -n "$goal" ]; then
          daily-goals add "$goal"
        fi
      '';

      negative-pomodoro = pkgs.writeShellScriptBin "negative-pomodoro" ''
        set -uo pipefail

        GOALS_DIR="$HOME/.local/share/daily-goals"
        STATE_FILE="$GOALS_DIR/.pomodoro-state"
        TODAY=$(date +%Y-%m-%d)
        TODAY_FILE="$GOALS_DIR/$TODAY.md"

        get_frontmatter() {
          ${pkgs.gawk}/bin/awk 'BEGIN{c=0} /^---$/{c++; next} c==1{print}' "$1"
        }

        get_body() {
          ${pkgs.gawk}/bin/awk 'BEGIN{c=0} /^---$/{c++; next} c>=2{print}' "$1"
        }

        write_back() {
          local fm="$1" body="$2" file="$3"
          {
            echo "---"
            echo "$fm"
            echo "---"
            echo "$body"
          } > "$file"
        }

        increment_sessions() {
          if [ -f "$TODAY_FILE" ]; then
            local fm body
            fm=$(get_frontmatter "$TODAY_FILE")
            body=$(get_body "$TODAY_FILE")
            fm=$(echo "$fm" | ${pkgs.yq-go}/bin/yq '.negative_pomodoro_sessions += 1')
            write_back "$fm" "$body" "$TODAY_FILE"
          fi
        }

        is_running() {
          if [ ! -f "$STATE_FILE" ]; then return 1; fi
          source "$STATE_FILE" 2>/dev/null || return 1
          if [ -n "''${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
            return 0
          fi
          return 1
        }

        format_time() {
          local secs="$1"
          printf "%d:%02d" $((secs / 60)) $((secs % 60))
        }

        case "''${1:-}" in
          start)
            neg_mins="''${2:-10}"
            work_mins="''${3:-10}"
            initial_phase="''${4:-negative}"

            # Kill existing timer if any
            if is_running; then
              source "$STATE_FILE"
              kill "$pid" 2>/dev/null || true
              sleep 0.5
            fi
            rm -f "$STATE_FILE"

            mkdir -p "$GOALS_DIR"
            negative-pomodoro _daemon "$initial_phase" "$neg_mins" "$work_mins" &
            ;;

          _daemon)
            phase="$2"
            negative_mins="$3"
            work_mins="$4"

            trap 'rm -f "$STATE_FILE"; ${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true; exit 0' TERM INT

            while true; do
              if [ "$phase" = "negative" ]; then
                duration=$((negative_mins * 60))
              else
                duration=$((work_mins * 60))
              fi

              end_time=$(($(date +%s) + duration))

              cat > "$STATE_FILE" << STATEEOF
phase=$phase
end_time=$end_time
pid=$$
negative_mins=$negative_mins
work_mins=$work_mins
STATEEOF

              if [ "$phase" = "negative" ]; then
                ${pkgs.sway}/bin/swaymsg workspace 10 2>/dev/null || true
                ${pkgs.sway}/bin/swaymsg mode negative 2>/dev/null || true
                ${pkgs.libnotify}/bin/notify-send -u critical "Negative Pomodoro" "NOTHING phase — ''${negative_mins}min"
                increment_sessions
              else
                ${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true
                ${pkgs.libnotify}/bin/notify-send "Negative Pomodoro" "WORK phase — ''${work_mins}min"
              fi

              # Wait loop — re-reads state file so adjust/skip can modify end_time
              while true; do
                if [ ! -f "$STATE_FILE" ]; then exit 0; fi
                source "$STATE_FILE" 2>/dev/null || exit 0
                now=$(date +%s)
                if [ "$now" -ge "$end_time" ]; then break; fi
                sleep 1
              done

              # Transition to next phase
              if [ "$phase" = "negative" ]; then
                phase="work"
              else
                phase="negative"
              fi
            done
            ;;

          cancel)
            if is_running; then
              source "$STATE_FILE"
              kill "$pid" 2>/dev/null || true
            fi
            rm -f "$STATE_FILE"
            ${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true
            ${pkgs.libnotify}/bin/notify-send "Negative Pomodoro" "Cancelled"
            ;;

          skip)
            if ! is_running; then exit 1; fi
            source "$STATE_FILE"
            # Set end_time to 0 — daemon's wait loop will see this and transition
            cat > "$STATE_FILE" << SKIPEOF
phase=$phase
end_time=0
pid=$pid
negative_mins=$negative_mins
work_mins=$work_mins
SKIPEOF
            ;;

          adjust)
            if ! is_running; then exit 1; fi
            adj_mins="''${2:-0}"
            source "$STATE_FILE"
            new_end=$((end_time + adj_mins * 60))
            now=$(date +%s)
            if [ "$new_end" -le "$now" ]; then
              new_end=$((now + 30))
            fi
            cat > "$STATE_FILE" << ADJEOF
phase=$phase
end_time=$new_end
pid=$pid
negative_mins=$negative_mins
work_mins=$work_mins
ADJEOF
            ;;

          panel)
            if ! is_running; then
              # Show preset picker
              choice=$(${pkgs.gum}/bin/gum choose \
                "10/10 (10min nothing, 10min work)" \
                "10/20 (10min nothing, 20min work)" \
                "20/20 (20min nothing, 20min work)" \
                "Custom" || true)

              case "$choice" in
                "10/10"*) negative-pomodoro start 10 10 ;;
                "10/20"*) negative-pomodoro start 10 20 ;;
                "20/20"*) negative-pomodoro start 20 20 ;;
                "Custom")
                  neg=$(${pkgs.gum}/bin/gum input --placeholder "Nothing minutes" --value "10" || true)
                  work=$(${pkgs.gum}/bin/gum input --placeholder "Work minutes" --value "20" || true)
                  if [ -n "$neg" ] && [ -n "$work" ]; then
                    negative-pomodoro start "$neg" "$work"
                  fi
                  ;;
                *) exit 0 ;;
              esac
              exit 0
            fi

            # Timer is running — show status with controls
            while is_running; do
              source "$STATE_FILE" 2>/dev/null || break
              now=$(date +%s)
              remaining=$((end_time - now))
              if [ "$remaining" -lt 0 ]; then remaining=0; fi
              time_str=$(format_time "$remaining")
              phase_upper=$(echo "$phase" | tr '[:lower:]' '[:upper:]')

              printf "\033[2J\033[H"
              ${pkgs.gum}/bin/gum style --border rounded --padding "0 1" --border-foreground 212 \
                "Negative Pomodoro" \
                "s: skip  c: cancel  +/-: adjust ±5min  q: quit"
              echo ""
              echo "  Phase: $phase_upper"
              echo "  Remaining: $time_str"
              echo "  Cycle: ''${negative_mins}min / ''${work_mins}min"

              if read -t 1 -n 1 key 2>/dev/null; then
                case "$key" in
                  s) negative-pomodoro skip ;;
                  c) negative-pomodoro cancel; exit 0 ;;
                  +) negative-pomodoro adjust 5 ;;
                  -) negative-pomodoro adjust -5 ;;
                  q) exit 0 ;;
                esac
              fi
            done

            echo "Timer ended."
            sleep 1
            ;;

          waybar)
            if ! is_running 2>/dev/null; then
              if [ -f "$STATE_FILE" ]; then
                rm -f "$STATE_FILE"
                ${pkgs.sway}/bin/swaymsg mode default 2>/dev/null || true
              fi
              ${pkgs.jq}/bin/jq -n '{text: "", class: "idle"}'
              exit 0
            fi

            source "$STATE_FILE"
            now=$(date +%s)
            remaining=$((end_time - now))
            if [ "$remaining" -lt 0 ]; then remaining=0; fi
            time_str=$(format_time "$remaining")

            if [ "$phase" = "negative" ]; then
              display="NOTHING $time_str"
              class="negative"
            else
              display="WORK $time_str"
              class="work"
            fi

            ${pkgs.jq}/bin/jq -n \
              --arg text "$display" \
              --arg class "$class" \
              '{text: $text, class: $class}'
            ;;

          *)
            echo "Usage: negative-pomodoro {start|cancel|skip|adjust|panel|waybar}"
            exit 1
            ;;
        esac
      '';
    in
    {
      # ActivityWatch (moved from activitywatch.nix)
      services.activitywatch = {
        enable = true;
        watchers.aw-watcher-window-wayland = {
          package = pkgs.aw-watcher-window-wayland;
        };
      };

      systemd.user.services.activitywatch-watcher-aw-watcher-window-wayland = {
        Unit = {
          After = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.mkForce "${pkgs.aw-watcher-window-wayland}/bin/aw-watcher-window-wayland";
        };
      };

      # Packages
      home.packages = [
        daily-ritual
        daily-goals
        daily-goals-add-popup
        negative-pomodoro
        pkgs.gum
        pkgs.yq-go
        pkgs.jq
        pkgs.libnotify
      ];
    };
}
