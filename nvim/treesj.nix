{
  plugins.treesj = {
    enable = true;
    autoLoad = true;
  };
  keymaps = [
    {
      key = "<leader>m";
      mode = [
        "n"
      ];
      action = "<cmd>TSJToggle<CR>";
    }
    {
      key = "<leader>s";
      mode = [
        "n"
      ];
      action = "<cmd>TSJSplit<CR>";
    }
    {
      key = "<leader>j";
      mode = [
        "n"
      ];
      action = "<cmd>TSJJoin<CR>";
    }
  ];
}
