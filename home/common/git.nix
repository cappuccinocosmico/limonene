{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = false; # Very scary
    settings = {
      user = {
        name = "Nicole Venner";
        email = "nvenner@protonmail.ch";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
