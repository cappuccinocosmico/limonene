{ inputs, lib, config, pkgs, ... }:  {
    programs.nushell  = {
      enable = true;
      extraEnv = "
$env.PATH = (
  $env.PATH | split row (char esep)
    | append /home/nicole/.local/bin
)
      ";
      shellAliases = {
        dlp-album = ''yt-dlp -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s" -x --audio-quality 10 --parse-metadata "playlist_index:%(track_number)s" --embed-metadata --embed-thumbnail'';
        dlp-lectures = ''yt-dlp --S "vcodec:av01 (bv*[height<=720]+ba)" --sponsorblock-remove all --embed-metadata --embed-chapters --embed-thumbnail --sub-langs all --write-subs --write-auto-subs --sub-format "srt" --embed-subs --merge-output-format "mkv" -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s"'';
      };
    };
    programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
    };
    programs.oh-my-posh= {
      enable = false;
      enableNushellIntegration = true;
    };
    programs.yazi = {
      enable = true;
      enableNushellIntegration = true;
    };
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  }
