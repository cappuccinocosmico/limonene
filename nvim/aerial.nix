{
  plugins.aerial = {
    enable = true;
    autoLoad = true;
    settings = {
      attach_mode = "global";
      backends = [
        "treesitter"
        "lsp"
        "markdown"
        "man"
      ];
      disable_max_lines = 5000;
      highlight_on_hover = true;
      ignore = {
        filetypes = [
          "gomod"
        ];
      };
      keymaps = {
        "<2-LeftMouse>" = "actions.jump";
        "<C-j>" = "actions.down_and_scroll";
        "<C-k>" = "actions.up_and_scroll";
        "<C-s>" = "actions.jump_split";
        "<C-v>" = "actions.jump_vsplit";
        "<CR>" = "actions.jump";
        "?" = "actions.show_help";
        H = "actions.tree_close_recursive";
        L = "actions.tree_open_recursive";
        O = "actions.tree_toggle_recursive";
        "[[" = "actions.prev_up";
        "]]" = "actions.next_up";
        "g?" = "actions.show_help";
        h = "actions.tree_close";
        l = "actions.tree_open";
        o = "actions.tree_toggle";
        p = "actions.scroll";
        q = "actions.close";
        zA = "actions.tree_toggle_recursive";
        zC = "actions.tree_close_recursive";
        zM = "actions.tree_close_all";
        zO = "actions.tree_open_recursive";
        zR = "actions.tree_open_all";
        zX = "actions.tree_sync_folds";
        za = "actions.tree_toggle";
        zc = "actions.tree_close";
        zm = "actions.tree_decrease_fold_level";
        zo = "actions.tree_open";
        zr = "actions.tree_increase_fold_level";
        zx = "actions.tree_sync_folds";
        "{" = "actions.prev";
        "}" = "actions.next";
      };
    };
  };
  keymaps = [
    {
      key = "<leader>o";
      mode = [ "n" ];
      action = "<cmd>AerialToggle<CR>";
    }
  ];
}
