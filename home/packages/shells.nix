{ inputs, lib, config, pkgs, ... }:  {
  programs.tmux  = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    sensibleOnTop = true;
    terminal = "screen-256color";
  };
  programs.foot  = {
    enable = true;
    settings.main.font = "Monoid Nerd Font:size=15";
    settings.colors.alpha=0.7;
    settings.colors.background="000000";
  };
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
  programs.fish  = {
    enable = true;
  };
  programs.oh-my-posh= {
    enable = false;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };
}
