{ ... }: {
  flake.modules.homeManager.vscode = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      profiles.default.userSettings = {
        "editor.formatOnSave" = false;
        "workbench.colorTheme" = "Dracula Theme";
      };
      profiles.default.extensions = with pkgs.vscode-marketplace; [
        dracula-theme.theme-dracula
        jnoortheen.nix-ide
        mechatroner.rainbow-csv
        rust-lang.rust-analyzer
        ms-playwright.playwright
      ];
    };
  };
}
