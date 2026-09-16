{pkgs, ...}: {
  flake.modules.homeManager.olympus = let
    olympusInstall = "/home/nicole/Downloads/linux.main";
  in {
    # Olympus' bundled .NET (Olympus.Sharp) needs libicu. The icu in
    # programs.nix-ld.libraries doesn't reach it reliably: nix-ld only
    # renames NIX_LD_LIBRARY_PATH to LD_LIBRARY_PATH when the latter is
    # unset, but the love AppRun sets its own LD_LIBRARY_PATH, so that
    # search path never includes nix-ld's libs and .NET fail-fasts with
    # "Couldn't find a valid ICU package"; Olympus then crashes with the
    # misleading "Failed to initialize filesystem: already initialized".
    # Setting globalization invariant avoids the ICU lookup entirely.
    # These vars travel down love -> Olympus.Sharp.
    # NOTE: don't fix this via the global LD_LIBRARY_PATH (nixld.nix) --
    # nix-ld's older nss breaks firefox then.
    packages = let
      olympus = pkgs.writeShellScriptBin "olympus" ''
        exec env \
          DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
          "${olympusInstall}/olympus" "$@"
      '';
    in [olympus];

    xdg.desktopEntries.Olympus = {
      name = "Olympus";
      comment = "Celeste Mod Manager";
      type = "Application";
      icon = "/home/nicole/Downloads/linux.main/olympus.png";
      exec = "olympus %u";
      categories = ["Game" "Application"];
      mimeType = ["x-scheme-handler/everest"];
    };
  };
}
