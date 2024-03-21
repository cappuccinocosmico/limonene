{ inputs, lib, config, pkgs, ... }:  {
    programs.nushell  = {
      enable = true;
      configFile.source = config/nicole-config.nu;
      envFile.source = config/nicole-env.nu;
      shellAliases = {
        dlp-album = ''yt-dlp -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s" -x --audio-quality 10 --parse-metadata "playlist_index:%(track_number)s" --embed-metadata --embed-thumbnail'';
        dlp-lectures = ''yt-dlp --S "vcodec:av01 (bv*[height<=720]+ba)" --sponsorblock-remove all --embed-metadata --embed-chapters --embed-thumbnail --sub-langs all --write-subs --write-auto-subs --sub-format "srt" --embed-subs --merge-output-format "mkv" -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s"'';
      };
    };
  }
