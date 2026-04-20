{...}: {
  flake.modules.homeManager.shells = {
    home.shellAliases = {
      dlp-album = ''yt-dlp -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s" -x --audio-quality 10 --parse-metadata "playlist_index:%(track_number)s" --embed-metadata --embed-thumbnail'';
      dlp-lectures = ''yt-dlp --S "vcodec:av01 (bv*[height<=720]+ba)" --sponsorblock-remove all --embed-metadata --embed-chapters --embed-thumbnail --sub-langs all --write-subs --write-auto-subs --sub-format "srt" --embed-subs --merge-output-format "mkv" -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s"'';
      dlp-concert = ''yt-dlp -f "bv*[height=720][vcodec*=av01]+ba/b[height=720]" --merge-output-format mkv --embed-metadata --embed-chapters'';
      ls = "eza";
      cat = "bat";
      find = "fd";
      deepqwen = ''qwen --openai-base-url https://api.deepinfra.com/v1/openai/ --openai-api-key $DEEPINFRA_API_KEY --model Qwen/Qwen3-Coder-480B-A35B-Instruct'';
    };

    programs.tmux = {
      enable = true;
      mouse = true;
      keyMode = "vi";
      sensibleOnTop = true;
      terminal = "screen-256color";
    };

    programs.zellij = {
      enable = true;
      settings = {
        pane_frames = false;
        show_startup_tips = false;
        default_shell = "fish";
      };
    };

    programs.direnv = {
      enable = true;
    };

    programs.eza = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.bat = {
      enable = true;
    };

    programs.fd = {
      enable = true;
    };

    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
    };

    programs.nushell = {
      enable = true;
    };

    programs.fish = {
      enable = true;
      functions = {
        envsource = ''
          for line in (cat $argv | grep -v '^#')
            set item (string split -m 1 '=' $line | string trim)
            set -gx $item[1] $item[2]
            echo "Exported key $item[1]"
          end
        '';
      };
      interactiveShellInit = ''
        if test -f "$HOME/.config/sops-nix/secrets/openrouter_api_key"
          set -gx OPENROUTER_API_KEY (cat "$HOME/.config/sops-nix/secrets/openrouter_api_key")
        end
      '';
    };
  };
}
