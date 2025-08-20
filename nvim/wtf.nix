{
  plugins.wtf = {
    enable = true;
  };
  keymaps = [
    {
      key = "<leader>wa";
      mode = [
        "n"
      ];
      action = "<cmd>Wtf<CR>";
    }
    {
      key = "<leader>ws";
      mode = [
        "n"
      ];
      action = "<cmd>WtfSearch google<CR>";
    }
    {
      key = "<leader>wh";
      mode = [
        "n"
      ];
      action = "<cmd>WtfHistory<CR>";
    }
    {
      key = "<leader>wg";
      mode = [
        "n"
      ];
      action = "<cmd>WtfGrepHistory<CR>";
    }
  ];
}
