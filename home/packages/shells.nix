{ inputs, lib, config, pkgs, ... }:  {
  home.shellAliases = {
    dlp-album = ''yt-dlp -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s" -x --audio-quality 10 --parse-metadata "playlist_index:%(track_number)s" --embed-metadata --embed-thumbnail'';
    dlp-lectures = ''yt-dlp --S "vcodec:av01 (bv*[height<=720]+ba)" --sponsorblock-remove all --embed-metadata --embed-chapters --embed-thumbnail --sub-langs all --write-subs --write-auto-subs --sub-format "srt" --embed-subs --merge-output-format "mkv" -o "%(playlist)s/%(playlist_autonumber)s - %(title)s.%(ext)s"'';
    ls = "eza";
    cat = "bat";
    find = "fd";
    nziina = ''eval "if set -q ZELLIJ; exit; else; eval (ssh-agent -c); /home/nicole/Documents/mycorrhizae/ziina/ziina -l 0.0.0.0:2222; end"'';
    # For this to work you might need to run the following:
    # set -Ux WAYLAND_DISPLAY wayland-1
    # set -Ux XDG_RUNTIME_DIR /run/user/1000
    ziina-sshget= ''echo "ssh -p 2222 $ZELLIJ_SESSION_NAME@apiarist" | tee /dev/tty | wl-copy'';
  };
  programs.tmux  = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    sensibleOnTop = true;
    terminal = "screen-256color";
  };
  programs.zellij = {
    enable=true;
    enableFishIntegration=true;
    settings={
      pane_frames=false;
      show_startup_tips=false;
    };
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
  programs.foot  = {
    enable = true;
  };
  programs.nushell  = {
    enable = true;
    extraEnv = "
$env.PATH = (
$env.PATH | split row (char esep)
  | append /home/nicole/.local/bin
)
    ";
  };
  programs.fish  = {
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
  };
}
