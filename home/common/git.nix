{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = false; # Very scary
    userName = "Nicole Venner";
    userEmail = "nvenner@protonmail.ch";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
