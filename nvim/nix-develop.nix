{
  plugins.nix-develop = {
    enable = true;
    autoLoad = true;
    ignoredVariables = {
      BASHOPTS = true;
      HOME = true;
      NIX_BUILD_TOP = true;
      NIX_ENFORCE_PURITY = true;
      NIX_LOG_FD = true;
      NIX_REMOTE = true;
      PPID = true;
      SHELL = true;
      SHELLOPTS = true;
      SSL_CERT_FILE = true;
      TEMP = true;
      TEMPDIR = true;
      TERM = true;
      TMP = true;
      TMPDIR = true;
      TZ = true;
      UID = true;
    };
    separatedVariables = {
      PATH = ":";
      XDG_DATA_DIRS = ":";
    };
  };
  keymaps = [
    {
      key = "<leader>nd";
      mode = [ "n" ];
      action = "<cmd>NixDevelop<CR>";
    }
  ];
}
