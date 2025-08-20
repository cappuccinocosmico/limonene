{
  plugins.zen-mode = {
    enable = true;
    autoLoad = true;
    settings = {
      window = {
        backdrop = 0.95;
        width = 0.8;
        height = 1;
        options.signcolumn = "no";
      };
      plugins = {
        options = {
          enabled = true;
          ruler = false;
          showcmd = false;
        };
        twilight.enabled = false;
        gitsigns.enabled = true;
        tmux.enabled = false;
      };
    };
  };
  keymaps = [
    {
      key = "<leader>zm";
      mode = [ "n" ];
      action = "<cmd>ZenMode<CR>";
    }
  ];
}
