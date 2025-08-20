{
  plugins.auto-save = {
    enable = true;
    autoLoad = true;
    #testsave
  };
  keymaps = [
    {
      key = "<C-s>";
      mode = [ "n" ];
      action = "<cmd>ASToggle<CR>";
    }
  ];
}
