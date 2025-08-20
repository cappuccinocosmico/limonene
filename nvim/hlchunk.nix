{
  plugins.hlchunk = {
    enable = true;
    autoLoad = true;
    settings = {
      blank = {
        enable = false;
      };
      chunk = {
        chars = {
          horizontal_line = "─";
          left_bottom = "╰";
          left_top = "╭";
          right_arrow = "─";
          vertical_line = "│";
        };
        enable = true;
        exclude_filetypes = {
          lazyterm = true;
          neo-tree = true;
        };
        style = {
          fg = "#91bef0";
        };
        use_treesitter = true;
      };
      indent = {
        chars = [
          "│"
        ];
        exclude_filetypes = {
          lazyterm = true;
          neo-tree = true;
        };
        style = {
          fg = "#45475a";
        };
        use_treesitter = false;
      };
      line_num = {
        style = "#91bef0";
        use_treesitter = true;
      };
    };
  };
}
