{ inputs, lib, config, pkgs, ... }:  {
  programs.vscode = {
    enable = true;
    userSettings = {
      # This property will be used to generate settings.json:
      # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
      "editor.formatOnSave" = false;
      "workbench.colorTheme" = "Dracula Theme";
    };
    # keybindings = [
    #   # See https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization
    #   {
    #     key = "shift+cmd+j";
    #     command = "workbench.action.focusActiveEditorGroup";
    #     when = "terminalFocus";
    #   }
    # ];

    # Some extensions require you to reload vscode, but unlike installing
    # from the marketplace, no one will tell you that. So after running
    # `darwin-rebuild switch`, make sure to restart vscode!
    extensions = with pkgs.vscode-marketplace; [
      # Search for vscode-extensions on https://search.nixos.org/packages
      dracula-theme.theme-dracula
      jnoortheen.nix-ide
      mechatroner.rainbow-csv
      rust-lang.rust-analyzer
      ms-playwright.playwright
    ];
  };
}
